//
//  Pagination.swift
//  Model
//
//  Created by Matteo Matassoni on 15/04/2021.
//

import Foundation

public struct Pagination {
    public let first: Int?
    public let last: Int?
    public let next: Int?
    public let prev: Int?
}

extension Pagination {
    init() {
        self.init(
            first: nil,
            last: nil,
            next: nil,
            prev: nil
        )
    }
}

// MARK: Equatable

extension Pagination: Equatable {}

// MARK: Hashable

extension Pagination: Hashable {}
