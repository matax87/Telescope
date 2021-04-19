//
//  ClientError.swift
//  StargazerApiClient
//
//  Created by Matteo Matassoni on 17/04/2021.
//

import Foundation

// https://docs.github.com/en/rest/overview/resources-in-the-rest-api#client-errors
struct ClientError: Error {
    let message: String
}

extension ClientError: Decodable {}

extension ClientError: LocalizedError {
    var errorDescription: String? {
        message
    }
}
