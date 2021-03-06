//
//  DependencyContainer.swift
//  Telescope
//
//  Created by Matteo Matassoni on 16/04/2021.
//

import Foundation
import ImageFetcher
import NetworkToolbox
import OSLog
import StargazerApiClient
import ViewModels

final class DependencyContainer {
    private let networkService: NetworkService

    init(networkService: NetworkService) {
        self.networkService = networkService
    }
}

// MARK: ViewModelFactory

extension DependencyContainer: ServiceFactory {
    func makeImageFetcher() -> ImageFetcherType {
        ImageFetcher(networkService: networkService)
    }

    func makeStargazerApiClient() -> StargazerApiClientType {
        StargazerApiClient(
            networkService: networkService,
            logger: makeNetworkingLogger()
        )
    }
}

// MARK: ViewModelFactory

extension DependencyContainer: ViewModelFactory {
    func makeFetcherViewModel() -> FetcherViewModel {
        FetcherViewModel(stargazerApiClient: makeStargazerApiClient())
    }

    func makeSelectRepositoryViewModel() -> SelectRepositoryViewModel {
        SelectRepositoryViewModel()
    }
}

// MARK: ViewControllerFactory

extension DependencyContainer: ViewControllerFactory {
    func makeListViewController() -> ListViewController {
        let result = ListViewController()
        result.imageFetcher = makeImageFetcher()
        return result
    }

    func makeMainViewController() -> MainViewController {
        MainViewController(
            selectRepositoryViewModel: makeSelectRepositoryViewModel(),
            fetcherViewModel: makeFetcherViewModel(),
            viewControllerFactory: self
        )
    }
}

// MARK: LoggerFactoryFactory

extension DependencyContainer: LoggerFactoryFactory {
    func makeNetworkingLogger() -> Logger {
        let bundleId = Bundle.main.bundleIdentifier!
        return Logger(
            subsystem: bundleId,
            category: "Networking"
        )
    }
}
