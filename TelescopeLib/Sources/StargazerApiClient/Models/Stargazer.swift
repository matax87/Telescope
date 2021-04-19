//
//  Stargazer.swift
//  Model
//
//  Created by Matteo Matassoni on 14/04/2021.
//

import Foundation

public struct Stargazer {
    public let starredAt: Date
    public let user: User
}

// MARK: Equatable

extension Stargazer: Equatable {}

// MARK: Hashable

extension Stargazer: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(user)
    }
}

// MARK: Decodable

extension Stargazer: Decodable {}

public extension Stargazer {
    struct NetworkResponse {
        public let items: [Stargazer]
        public let pagination: Pagination
    }
}
