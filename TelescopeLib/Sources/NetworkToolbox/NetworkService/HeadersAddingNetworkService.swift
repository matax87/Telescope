//
//  HeadersAddingNetworkService.swift
//  NetworkToolbox
//
//  Created by Matteo Matassoni on 14/04/2021.
//

import Foundation

public final class HeadersAddingNetworkService: NetworkService {
    let wrapped: NetworkService
    let headers: [String: String]

    public init(
        wrapped: NetworkService,
        headers: [String: String]
    ) {
        self.wrapped = wrapped
        self.headers = headers
    }

    public func fetchData(
        with request: URLRequest,
        completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void
    ) -> NTBCancellable {
        var newRequest = request
        for (key, value) in headers {
            newRequest.setValue(value, forHTTPHeaderField: key)
        }
        return wrapped.fetchData(
            with: newRequest,
            completionHandler: completionHandler
        )
    }
}

public extension NetworkService {
    func addingJSONHeaders() -> NetworkService {
        HeadersAddingNetworkService(
            wrapped: self,
            headers: [
                "Content-Type": "application/json",
                "Accept": "application/json"
            ]
        )
    }
}
