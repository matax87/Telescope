import XCTest
import Combine
@testable import ViewModels

final class SelectRepositoryViewModelTests: XCTestCase {
    let viewModel = SelectRepositoryViewModel()
    var subscriptions: Set<AnyCancellable> = []

    func testWithValidTypedRepositoryName() {
        let expectation = self.expectation(
            description: "selectRepositoryExpectation"
        )
        viewModel.$selectedRepository
            .dropFirst()
            .sink { selectedRepositoryOrNl in
                if selectedRepositoryOrNl != nil {
                    expectation.fulfill()
                }
            }
            .store(in: &subscriptions)

        viewModel.searchedText = "test/test"

        wait(for: [expectation], timeout: 3)
    }

    func testWithInvalidTypedRepositoryName() {
        let expectation = self.expectation(
            description: "invalidRepositoryExpectation"
        )
        viewModel.$error
            .dropFirst()
            .sink { errorOrNil in
                if errorOrNil != nil {
                    expectation.fulfill()
                }
            }
            .store(in: &subscriptions)

        viewModel.searchedText = "test"

        wait(for: [expectation], timeout: 3)
    }
}
