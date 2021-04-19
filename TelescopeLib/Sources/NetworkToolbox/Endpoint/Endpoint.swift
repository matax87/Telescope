//
//  Endpoint.swift
//  NetworkToolbox
//
//  Created by Matteo Matassoni on 14/04/2021.
//

import Foundation

public struct Endpoint {
    public var path: String
    public var queryItems: [URLQueryItem]

    public init(
        path: String,
        queryItems: [URLQueryItem] = []
    ) {
        self.path = path
        self.queryItems = queryItems
    }
}
