//
//  LoggingNetworkService.swift
//  NetworkToolbox
//
//  Created by Matteo Matassoni on 14/04/2021.
//

import Foundation
import OSLog

public final class LoggingNetworkService: NetworkService {
    private static let notAvailable = "N/A"

    let wrapped: NetworkService
    let logger: Logger
    
    public init(wrapped: NetworkService, logger: Logger) {
        self.wrapped = wrapped
        self.logger = logger
    }
    
    public func fetchData(
        with request: URLRequest,
        completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void
    ) -> NTBCancellable{
        log(request: request)
        return wrapped.fetchData(with: request) { [weak self] data, response, error in
            self?.log(
                response: response,
                data: data,
                error: error
            )
            completionHandler(data, response, error)
        }
    }
}

// MARK: Private APIs
private extension LoggingNetworkService {

    func log(request: URLRequest) {
        logger.debug("REQUEST: \(request.url?.absoluteString ?? Self.notAvailable)")
        logger.debug("METHOD: \(request.httpMethod ?? Self.notAvailable)")

        if let httpHeaders = request.allHTTPHeaderFields,
           !httpHeaders.isEmpty {
            logger.debug("HEADERS:")
            for (key, value) in httpHeaders {
                logger.debug("- \(key): \(value)")
            }
        }

        if let contentType = request.contentType {
            logger.debug("Content-Type: \(contentType)")
        }

        if let bodyData = request.httpBody {
            let encoding: String.Encoding = request.charset() ?? .utf8
            if let bodyContent = String(data: bodyData, encoding: encoding) {
                logger.debug("BODY START")
                logger.debug("\(bodyContent)")
                logger.debug("BODY END")
            }
        }
    }

    func log(response: URLResponse?, data: Data?, error: Error?) {
        let statusCode: String? = response
            .flatMap { $0 as? HTTPURLResponse }
            .flatMap { $0.statusCode }
            .flatMap(String.init)
        logger.debug("RESPONSE: \(statusCode ?? Self.notAvailable)")
        logger.debug("FROM: \(response?.url?.absoluteString ?? Self.notAvailable)")

        if let httpHeaders = (response as? HTTPURLResponse)?.allHeaderFields,
           !httpHeaders.isEmpty {
            logger.debug("HEADERS:")
            for (key, value) in httpHeaders {
                logger.debug("- \(key): \(String(describing:value))")
            }
        }

        if let contentType = (response as? HTTPURLResponse)?.contentType {
            logger.debug("Content-Type: \(contentType)")
        }

        if let bodyData = data {
            let encoding: String.Encoding = (response as? HTTPURLResponse)?.charset() ?? .utf8
            if let bodyContent = String(data: bodyData, encoding: encoding) {
                logger.debug("BODY START")
                logger.debug("\(bodyContent)")
                logger.debug("BODY END")
            }
        } else if let error = error {
            logger.debug("ERROR: \(error.localizedDescription)")
        }
    }
}

private extension String.Encoding {
    struct UnknownEncodingError: Error {
        let value: String
    }

    init(value: String) throws {
        // TODO: Add other cases
        switch value {
        case let charset where charset.caseInsensitiveCompare("UTF-8") == .orderedSame:
            self = .utf8
        case let charset where charset.caseInsensitiveCompare("utf-16") == .orderedSame:
            self = .utf16
        case let charset where charset.caseInsensitiveCompare("UTF-16BE") == .orderedSame:
            self = .utf16BigEndian
        case let charset where charset.caseInsensitiveCompare("UTF-16LE") == .orderedSame:
            self = .utf16LittleEndian
        case let charset where charset.caseInsensitiveCompare("UTF-32") == .orderedSame:
            self = .utf32
        case let charset where charset.caseInsensitiveCompare("UTF-32") == .orderedSame:
            self = .utf32
        case let charset where charset.caseInsensitiveCompare("ascii") == .orderedSame:
            self = .ascii
        default:
            throw UnknownEncodingError(value: value)
        }
    }
}

private typealias ContentTypeValue = String
private var contentTypeKey = "Content-Type"

private func encoding(from contentType: ContentTypeValue) -> String.Encoding {
    let defaultEncoding: String.Encoding = .utf8

    let parts = contentType.split(separator: ";")
    guard !parts.isEmpty
    else { return defaultEncoding }

    for parameter in parts[1...] {
        let parameterParts = parameter
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .split(separator: "=")
        guard parameterParts.count >= 2
        else { continue }

        let token = parameterParts[0]
        let value = String(parameterParts[1])
        if token.caseInsensitiveCompare("charset") == .orderedSame {
            do {
                let encoding = try String.Encoding(value: value)
                return encoding
            } catch {
                print(error.localizedDescription)
                return defaultEncoding
            }
        }
    }

    return defaultEncoding
}

private extension URLRequest {
    var contentType: String? {
        allHTTPHeaderFields?[contentTypeKey]
    }

    func charset() -> String.Encoding? {
        contentType.flatMap { encoding(from: $0) }
    }
}

private extension HTTPURLResponse {
    var contentType: String? {
        allHeaderFields[contentTypeKey] as? String
    }

    func charset() -> String.Encoding? {
        contentType.flatMap { encoding(from: $0) }
    }
}

extension NetworkService {
    public func addingLogger(_ logger: Logger) -> NetworkService {
        LoggingNetworkService(wrapped: self, logger: logger)
    }
}
