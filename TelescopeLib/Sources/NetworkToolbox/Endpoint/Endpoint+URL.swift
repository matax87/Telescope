//
//  Endpoint+URL.swift
//  NetworkToolbox
//
//  Created by Matteo Matassoni on 14/04/2021.
//

import Foundation

public extension Endpoint {
    func makeURL(withHost host: String) -> URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = host
        components.path = "/" + path
        components.queryItems = queryItems.isEmpty ? nil : queryItems

        guard let url = components.url
        else { preconditionFailure("Invalid URL components: \(components)") }

        return url
    }
}
