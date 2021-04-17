//
//  MainViewModel.swift
//  ViewModels
//
//  Created by Matteo Matassoni on 16/04/2021.
//

import Foundation
import Combine
import StargazerApiClient
import StargazerApiClientCombine

public final class MainViewModel {
    // MARK: Public Publishers
    public var loadingPublisher: AnyPublisher<Bool, Never> {
        loadingSubject.eraseToAnyPublisher()
    }

    public var errorPublisher: AnyPublisher<Error, Never> {
        errorSubject.eraseToAnyPublisher()
    }

    public var stargazersPublisher: AnyPublisher<[Stargazer], Never> {
        stargazersSubject.eraseToAnyPublisher()
    }

    @Published public var repository: String? = nil

    // MARK: Private Combine Properties
    private var subscriptions: Set<AnyCancellable> = []
    private let loadingSubject = PassthroughSubject<Bool, Never>()
    private let errorSubject = PassthroughSubject<Error, Never>()
    private let stargazersSubject = CurrentValueSubject<[Stargazer], Never>([])

    // MARK: Private Api Client Properties
    private let stargazerApiClient: StargazerApiClientType
    private let firstPage: Int
    private let pageSize: Int

    // MARK: Private Pagination Properties
    private var nextPage: Int?
    private var currentRepository: String?
    private var isLoading = false
    private var hasSeenLastPage = false

    // MARK: Initialization
    public init(
        stargazerApiClient: StargazerApiClientType,
        firstPage: Int = 1,
        pageSize: Int = 10
    ) {
        self.stargazerApiClient = stargazerApiClient
        self.firstPage = firstPage
        self.pageSize = pageSize

        setupBindings()
    }

    // MARK: Public APIs
    public func fetchStargazers(
        ofRepository repository: String,
        refresh: Bool = false
    ) {
        guard
            !isLoading,
              !hasSeenLastPage
        else { return }

        let invalidate = refresh || repository != currentRepository
        if invalidate {
            nextPage = firstPage
            hasSeenLastPage = false
            stargazersSubject.send([])
        }
        currentRepository = repository

        fetchStagazerList(
            of: repository,
            page: nextPage,
            pageSize: pageSize
        )
    }

    public func fetchMoreStargazers() {
        guard let currentRepository = currentRepository
        else { return }
        
        fetchStargazers(ofRepository: currentRepository)
    }
}

// MARK: Private APIs
private extension MainViewModel {
    func setupBindings() {
        $repository
            .sink { [weak self] repositoryOrNil in
                if let repository = repositoryOrNil {
                    self?.fetchStargazers(ofRepository: repository)
                }
            }
            .store(in: &subscriptions)
    }

    func fetchStagazerList(
        of repositoryName: String,
        page: Int? = nil,
        pageSize: Int? = nil
    ) {
        isLoading = true
        loadingSubject.send(true)
        stargazerApiClient.fetchStagazerList(
            of: repositoryName,
            page: page,
            pageSize: pageSize
        )
        .sink { [weak self] completion in
            self?.isLoading = false
            self?.loadingSubject.send(false)

            switch completion {
            case .failure(let error):
                self?.errorSubject.send(error)
            case .finished:
                break
            }
        } receiveValue: { [weak self] response in
            self?.nextPage = response.pagination.next
            self?.hasSeenLastPage = response.pagination.next == nil
            let currentItems = self?.stargazersSubject.value ?? []
            self?.stargazersSubject.send(currentItems + response.items)
        }
        .store(in: &subscriptions)
    }
}
