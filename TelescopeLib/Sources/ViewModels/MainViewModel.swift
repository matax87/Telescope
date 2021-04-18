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
    @Published public var selectedRepository: String? = nil

    @Published public private(set) var isLoading = false
    @Published public private(set) var error: Error?
    @Published public private(set) var stargazers: [Stargazer]?

    @Published public private(set) var hasMoreData = true

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
    public func fetchStargazers(ofRepository repository: String) {
        performFetchStargazers(ofRepository: repository)
    }

    public func fetchMoreStargazers() {
        guard let selectedRepository = selectedRepository
        else { return }
        
        performFetchStargazers(ofRepository: selectedRepository)
    }

    public func refreshStargazers() {
        guard let selectedRepository = selectedRepository
        else { return }

        performFetchStargazers(
            ofRepository: selectedRepository,
            isRefresh: true
        )
    }
}

// MARK: Private APIs
private extension MainViewModel {
    func setupBindings() {
        $selectedRepository
            .sink { [weak self] selectedRepository in
                if let nonOptSelectedRepository = selectedRepository {
                    self?.fetchStargazers(ofRepository: nonOptSelectedRepository)
                }
            }
            .store(in: &subscriptions)
    }

    func performFetchStargazers(
        ofRepository repository: String,
        isRefresh: Bool = false
    ) {
        guard !isLoading,
              hasMoreData || isRefresh
        else { return }

        let invalidate = isRefresh || repository != selectedRepository
        if invalidate {
            nextPage = firstPage
            stargazers = nil
            hasMoreData = true
        }

        let page = nextPage
        isLoading = true
        stargazerApiClient.fetchStagazerList(
            of: repository,
            page: page,
            pageSize: pageSize
        )
        .sink { [weak self] completion in
            self?.isLoading = false

            switch completion {
            case .failure(let error):
                self?.error = error
            case .finished:
                break
            }
        } receiveValue: { [weak self] response in
            guard let self = self
            else { return }

            self.nextPage = response.pagination.next
            self.hasMoreData = response.pagination.last == page ||
                response.pagination.next != nil
            if let stargazers = self.stargazers {
                self.stargazers = stargazers + response.items
            } else {
                self.stargazers = response.items
            }
        }
        .store(in: &subscriptions)
    }
}
