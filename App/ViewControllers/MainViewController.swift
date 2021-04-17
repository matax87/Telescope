//
//  MainViewController.swift
//  Stargazers
//
//  Created by Matteo Matassoni on 14/04/2021.
//

import UIKit
import Combine
import ViewModels
import StargazerApiClient

class MainViewController: UIViewController {
    let viewModel: MainViewModel
    let viewControllerFactory: ViewControllerFactory

    weak var coordinator: MainCoordinator?

    private var subscriptions: Set<AnyCancellable> = []

    private lazy var searchBar: UISearchBar = { searchBar in
        self.setupSearchBar(searchBar)
        return searchBar
    }(UISearchBar())

    private lazy var resultsVC: ListViewController = {
        let result = self.viewControllerFactory.makeListViewController()
        result.scrollViewDidScrollHandler = { [weak self] in
            self?.pagination(scrollView: $0)
        }
        return result
    }()

    // MARK: Initalization
    init(
        viewModel: MainViewModel,
        viewControllerFactory: ViewControllerFactory
    ) {
        self.viewModel = viewModel
        self.viewControllerFactory = viewControllerFactory
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("\(#function) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupViewHierarchy()
        setupChilds()
        setupBindings()
    }
}

// MARK: UISearchBarDelegate
extension MainViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        viewModel.repository = searchBar.text
    }
}

// MARK: Private APIs
private extension MainViewController {
    func setupChilds() {
        embedChild(resultsVC)
    }

    func setupViewHierarchy() {
        searchBar.sizeToFit()
        navigationItem.titleView = searchBar
    }

    func setupBindings() {
        viewModel.loadingPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak resultsVC] isLoading in
                guard let refreshControl = resultsVC?.refreshControl
                else { return }

                if isLoading {
                    refreshControl.beginRefreshing()
                } else {
                    refreshControl.endRefreshing()
                }
            })
            .store(in: &subscriptions)

        viewModel.errorPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                self?.showError(error)
            }.store(in: &subscriptions)

        viewModel.stargazersPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak resultsVC] in
                resultsVC?.items = $0
            }
            .store(in: &subscriptions)
    }

    func setupSearchBar(_ searchBar: UISearchBar) {
        searchBar.placeholder = NSLocalizedString(
            "search_repo_placeholder",
            comment: "Search repository placeholder"
        )
        searchBar.searchTextField.autocapitalizationType = .none
        searchBar.searchBarStyle = .prominent
        searchBar.delegate = self
    }
}

// MARK: Private Pagination APIs
private extension MainViewController {
    func pagination(scrollView: UIScrollView) {
        guard scrollView.checkIfNextPageIsRequired()
        else { return }

        viewModel.fetchMoreStargazers()
    }
}

private extension UIScrollView {
    func checkIfNextPageIsRequired() -> Bool {
        let yContentOffset = contentOffset.y
        let contentHeight = contentSize.height
        return yContentOffset >= contentHeight - bounds.height
    }
}
