//
//  StatusCodeCheckingNetworkService.swift
//  NetworkToolbox
//
//  Created by Matteo Matassoni on 14/04/2021.
//

import Foundation

public final class StatusCodeCheckingNetworkService: NetworkService {
    let wrapped: NetworkService

    public init(wrapped: NetworkService) {
        self.wrapped = wrapped
    }

    public func fetchData(
        with request: URLRequest,
        completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void
    ) -> NTBCancellable {
        wrapped.fetchData(with: request) { data, response, error in
            let getStatusCodeError = {
                response
                    .flatMap { $0 as? HTTPURLResponse }
                    .flatMap { $0.networkError }
            }
            completionHandler(
                data,
                response,
                error ?? getStatusCodeError()
            )
        }
    }
}

private extension HTTPURLResponse {
    var networkError: NetworkError? {
        switch statusCode {
        case 200 ... 299:
            return nil
        case 300 ... 399:
            return .redirectionError
        case 400 ... 499:
            return .clientError
        case 500 ... 599:
            return .serverError
        case 600:
            return .invalidRequest
        default:
            return .unknownError
        }
    }
}

extension NetworkService {
    public func checkingStatusCodes() -> NetworkService {
        StatusCodeCheckingNetworkService(wrapped: self)
    }
}
