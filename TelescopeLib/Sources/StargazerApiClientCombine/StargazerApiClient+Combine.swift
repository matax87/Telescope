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
        ofRepositoryWithOwner owner: String,
        name: String,
        page: Int? = nil,
        pageSize: Int? = nil
    ) -> AnyPublisher<Stargazer.NetworkResponse, Error> {
        Future { promise in
            _ = fetchStagazerList(
                ofRepositoryWithOwner: owner,
                name: name,
                page: page,
                pageSize: pageSize,
                completionHandler: promise
            )
        }
        .eraseToAnyPublisher()
    }
}
