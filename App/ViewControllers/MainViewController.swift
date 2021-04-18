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
        result.refreshControl.addTarget(
            self,
            action: #selector(refresh(sender:)),
            for: .valueChanged
        )
        result.willDisplayLastItemHandler = { [weak self] in
            self?.viewModel.fetchMoreStargazers()
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
        viewModel.selectedRepository = "matax87/texowl"
    }
}

// MARK: UISearchBarDelegate
extension MainViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        viewModel.selectedRepository = searchBar.text
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
        viewModel.$selectedRepository
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak searchBar] in
                searchBar?.text = $0
            })
            .store(in: &subscriptions)

        viewModel.$isLoading
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

        viewModel.$error
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                if let error = $0 {
                    self?.showError(error)
                }
            }.store(in: &subscriptions)

        viewModel.$stargazers
            .receive(on: DispatchQueue.main)
            .sink { [weak resultsVC] in
                resultsVC?.items = $0 ?? []
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

// MARK: Private Refresh APIs
private extension MainViewController {
    @objc func refresh(sender: Any?) {
        viewModel.refreshStargazers()
    }
}

private extension UIScrollView {
    func checkIfNextPageIsRequired() -> Bool {
        let yContentOffset = contentOffset.y
        let contentHeight = contentSize.height
        print(yContentOffset, contentHeight, bounds.height)
        return yContentOffset >= contentHeight - bounds.height
    }
}
