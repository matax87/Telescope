import XCTest
@testable import NetworkToolbox

final class EndpointTests: XCTestCase {
    let host = "test"

    func testBasicRequestGeneration() throws {
        let endpoint = Endpoint(path: "path")
        let url = endpoint.makeURL(withHost: host)

        XCTAssertEqual(
            url.absoluteString,
            "https://test/path"
        )
    }

    func testGeneratingRequestWithQueryItems() throws {
        let endpoint = Endpoint(path: "path", queryItems: [
            URLQueryItem(name: "a", value: "1"),
            URLQueryItem(name: "b", value: "2")
        ])
        let url = endpoint.makeURL(withHost: host)

        XCTAssertEqual(
            url.absoluteString,
            "https://test/path?a=1&b=2"
        )
    }
}
