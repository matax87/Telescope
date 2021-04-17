//
//  URLSession+NetworkService.swift
//  NetworkToolbox
//
//  Created by Matteo Matassoni on 14/04/2021.
//

import Foundation

extension URLSession: NetworkService {
    public func fetchData(
        with request: URLRequest,
        completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void
    ) -> NTBCancellable {
        let task = dataTask(
            with: request,
            completionHandler: completionHandler
        )
        task.resume()
        return task
    }
}
