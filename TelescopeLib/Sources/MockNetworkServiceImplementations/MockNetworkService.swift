import Combine
import Foundation
import NetworkToolbox

public class MockNetworkService: NetworkService {
    let url: URL
    let data: Data

    public init(url: URL, data: Data) {
        self.url = url
        self.data = data
    }

    public func fetchData(
        with request: URLRequest,
        completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void
    ) -> NTBCancellable {
        guard
            let method = request.httpMethod,
            let requestedURL = request.url
        else {
            completionHandler(
                nil,
                nil,
                URLError(.badURL)
            )
            return NTBAnyCancellable {}
        }

        guard requestedURL == url
        else {
            completionHandler(
                nil,
                .notFoundResponse(url),
                URLError(.fileDoesNotExist)
            )
            return NTBAnyCancellable {}
        }

        completionHandler(
            data,
            .successResponse(url),
            nil
        )
        return NTBAnyCancellable {}
    }
}

private extension URLResponse {
    static func successResponse(_ url: URL) -> URLResponse {
        HTTPURLResponse(
            url: url,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )!
    }

    static func notFoundResponse(_ url: URL) -> URLResponse {
        HTTPURLResponse(
            url: url,
            statusCode: 404,
            httpVersion: nil,
            headerFields: nil
        )!
    }
}
