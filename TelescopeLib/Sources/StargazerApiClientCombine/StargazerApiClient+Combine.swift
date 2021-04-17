//
//  File.swift
//  StargazerApiClientCombine
//
//  Created by Matteo Matassoni on 16/04/2021.
//

import Foundation
import Combine
import StargazerApiClient

extension StargazerApiClientType {
    public func fetchStagazerList(
        of repositoryName: String,
        page: Int? = nil,
        pageSize: Int? = nil
    ) -> AnyPublisher<Stargazer.NetworkResponse, Error> {
        Future { promise in
            _ = fetchStagazerList(
                of: repositoryName,
                page: page,
                pageSize: pageSize,
                completionHandler: promise
            )
        }
        .eraseToAnyPublisher()
    }

    public func fetchStagazerList(
        of repository: Repository,
        page: Int? = nil,
        pageSize: Int? = nil
    ) -> AnyPublisher<Stargazer.NetworkResponse, Error> {
        Future { promise in
            _ = fetchStagazerList(
                of: repository,
                page: page,
                pageSize: pageSize,
                completionHandler: promise
            )
        }
        .eraseToAnyPublisher()
    }
}
