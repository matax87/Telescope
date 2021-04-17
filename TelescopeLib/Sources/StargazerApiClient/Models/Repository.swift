//
//  Repository.swift
//  Model
//
//  Created by Matteo Matassoni on 14/04/2021.
//

import Foundation

public struct Repository {
    public let owner: String
    public let name: String

    public init(owner: String, name: String) {
        self.owner = owner
        self.name = name
    }
}

extension Repository {
    struct InvalidRepositoryError: Error {
        let value: String
    }
    public init(value: String) throws {
        let parts = value.split(separator: "/")
        guard parts.count == 2
        else { throw InvalidRepositoryError(value: value) }

        self.init(
            owner: String(parts[0]),
            name: String(parts[1])
        )
    }
}

// MARK: CustomStringConvertible
extension Repository: CustomStringConvertible {
    public var description: String {
        "\(owner)/\(name)"
    }
}
