//
//  StargazerApiClient.swift
//  StargazerApiClient
//
//  Created by Matteo Matassoni on 16/04/2021.
//

import Foundation
import Combine
import NetworkToolbox
import OSLog

public typealias StargazerNetworkResult =
    (Result<Stargazer.NetworkResponse, Error>) -> Void

public protocol StargazerApiClientType {
    func fetchStagazerList(
        ofRepositoryWithOwner owner: String,
        name: String,
        page: Int?,
        pageSize: Int?,
        completionHandler: @escaping StargazerNetworkResult
    ) -> NTBCancellable
}

extension StargazerApiClientType {

    public func fetchStagazerList(
        ofRepositoryWithOwner owner: String,
        name: String,
        page: Int? = nil,
        pageSize: Int? = nil,
        completionHandler: @escaping StargazerNetworkResult
    ) -> NTBCancellable {
        fetchStagazerList(
            ofRepositoryWithOwner: owner,
            name: name,
            page: page,
            pageSize: pageSize,
            completionHandler: completionHandler
        )
    }
}

public final class StargazerApiClient: StargazerApiClientType {
    let networkService: NetworkService

    public init(networkService: NetworkService) {
        self.networkService = networkService
            .addingLogger(Logger(subsystem: "io.stargazerapi", category: "networking"))
            .addingStarMediaTypeHeaders()
            .checkingStatusCodes()
    }

    public func fetchStagazerList(
        ofRepositoryWithOwner owner: String,
        name: String,
        page: Int?,
        pageSize: Int?,
        completionHandler: @escaping StargazerNetworkResult
    ) -> NTBCancellable {
        let url = Endpoint.listStargazers(
            ofRepositoryWithOwner: owner,
            name: name,
            page: page,
            pageSize: pageSize
        )
        .makeURL(withHost: GithubConstants.Host.api)
        
        let urlRequest = URLRequest(url: url)

        return networkService
            .fetchData(with: urlRequest) { data, response, error in
                switch (data, error) {
                case let (data?, NetworkError.clientError?):
                    do {
                        let clientError = try JSONDecoder().decode(
                            ClientError.self,
                            from: data
                        )
                        completionHandler(.failure(clientError))
                    } catch _ {
                        completionHandler(.failure(error!))
                    }
                case let (_, error?):
                    completionHandler(.failure(error))
                case let (data?, _):
                    do {
                        // Extract pagination information from http headers
                        let pagination = response
                            .flatMap { $0 as? HTTPURLResponse }
                            .flatMap { $0.allHeaderFields }
                            .flatMap(PaginationParser.parse(httpHeaders:))
                            ?? Pagination()

                        // Decode stargazer list from JSON
                        let decoder = JSONDecoder()
                        decoder.keyDecodingStrategy = .convertFromSnakeCase
                        decoder.dateDecodingStrategy = .iso8601
                        let stargazerList = try decoder.decode(
                            [Stargazer].self,
                            from: data
                        )

                        // Assemble the final network response using with
                        // pagination and stargazer list
                        let networkResponse = Stargazer.NetworkResponse(
                            items: stargazerList,
                            pagination: pagination
                        )

                        completionHandler(.success(networkResponse))
                    } catch let decodingError {
                        completionHandler(.failure(decodingError))
                    }
                case (nil, nil):
                    completionHandler(.failure(NetworkError.dataError))
                }
            }
    }
}
