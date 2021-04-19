//
//  NetworkError.swift
//  NetworkToolbox
//
//  Created by Matteo Matassoni on 14/04/2021.
//

import Foundation

public enum NetworkError: Error {
    /// URL is nil
    case missingUrl

    /// Parameters were nil
    case parametersNil

    /// Parameter encoding failed
    case encodingFailed

    /// Redirection error
    case redirectionError

    /// Client Error
    case clientError

    /// Server Error
    case serverError

    /// Invalid Request
    case invalidRequest

    /// Unknown Error
    case unknownError

    /// Error getting valid data
    case dataError
}
