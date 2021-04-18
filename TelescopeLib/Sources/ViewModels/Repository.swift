//
//  Repository.swift
//  ViewModels
//
//  Created by Matteo Matassoni on 14/04/2021.
//

import Foundation

public struct Repository: Hashable, Equatable {
    public let owner: String
    public let name: String

    public init(owner: String, name: String) {
        self.owner = owner
        self.name = name
    }
}

extension Repository {
    struct InvalidRepositoryError: LocalizedError {
        let value: String

        var errorDescription: String? {
            .localizedStringWithFormat(
                NSLocalizedString(
                    "invalid_repository_value_format",
                    bundle: Bundle.module,
                    comment: "Invalid repository value format"
                ),
                value
            )
        }

        var failureReason: String? {
            NSLocalizedString(
                "invalid_repository_failure_reason",
                bundle: Bundle.module,
                comment: "Invalid repository failure reason"
            )
        }
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

