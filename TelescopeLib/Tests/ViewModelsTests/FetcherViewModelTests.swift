import Combine
import MockNetworkServiceImplementations
import StargazerApiClient
@testable import ViewModels
import XCTest

final class FetcherViewModelTests: XCTestCase {
    var subscriptions: Set<AnyCancellable> = []

    func testFetchStargazers() {
        let mockedStargazerApiClient = StargazerApiClient(
            networkService: MockNetworkService(
                url: URL(
                    string: "https://api.github.com/repos/test/test/stargazers?page=1&per_page=10"
                )!,
                data: mockFixture(
                    name: "stargazers",
                    withExtension: "json"
                )
            )
        )
        let viewModel = FetcherViewModel(
            stargazerApiClient: mockedStargazerApiClient
        )
        var stargazers: [Stargazer]!
        let expectation = self.expectation(
            description: "stargazersExpectation"
        )
        viewModel.$stargazers
            .dropFirst(2)
            .sink {
                stargazers = $0
                expectation.fulfill()
            }
            .store(in: &subscriptions)

        viewModel.selectedRepository = Repository(
            owner: "test",
            name: "test"
        )

        wait(for: [expectation], timeout: 3)

        XCTAssertEqual(
            stargazers.count,
            1
        )
        let stargazer = stargazers[0]
        XCTAssertEqual(
            stargazer.user.login,
            "schacon"
        )
        XCTAssertEqual(
            stargazer.user.avatarUrl,
            "https://avatars.githubusercontent.com/u/70?v=4"
        )
    }

    func testFetchStargazersWithError() {
        let mockedStargazerApiClient = StargazerApiClient(
            networkService: MockNetworkService(
                url: URL(
                    string: "https://api.github.com/repos/test/test/stargazers?page=1&per_page=10"
                )!,
                data: "invalid json".data(using: .utf8)!
            )
        )
        let viewModel = FetcherViewModel(
            stargazerApiClient: mockedStargazerApiClient
        )
        let expectation = self.expectation(
            description: "errorExpectation"
        )
        viewModel.$error
            .dropFirst()
            .sink { errorOrNil in
                if errorOrNil != nil {
                    expectation.fulfill()
                }
            }
            .store(in: &subscriptions)

        viewModel.selectedRepository = Repository(
            owner: "test",
            name: "test"
        )

        wait(for: [expectation], timeout: 3)
    }
}
