//
//  MainViewController.swift
//  Telescope
//
//  Created by Matteo Matassoni on 14/04/2021.
//

import UIKit
import Combine
import ViewModels

class MainViewController: UIViewController {
    let selectRepositoryViewModel: SelectRepositoryViewModel
    let fetcherViewModel: FetcherViewModel
    let viewControllerFactory: ViewControllerFactory

    weak var coordinator: MainCoordinator?

    private var subscriptions: Set<AnyCancellable> = []

    private lazy var searchController: UISearchController = { searchController in
        self.configureSearchBar(searchController.searchBar)
        return searchController
    }(UISearchController(searchResultsController: nil))

    private lazy var resultsVC: ListViewController = {
        let result = self.viewControllerFactory.makeListViewController()
        result.refreshControl.addTarget(
            self,
            action: #selector(refresh(sender:)),
            for: .valueChanged
        )
        result.willDisplayLastItemHandler = { [weak self] in
            self?.fetcherViewModel.fetchMoreStargazers()
        }
        return result
    }()

    // MARK: Initalization
    init(
        selectRepositoryViewModel: SelectRepositoryViewModel,
        fetcherViewModel: FetcherViewModel,
        viewControllerFactory: ViewControllerFactory
    ) {
        self.selectRepositoryViewModel = selectRepositoryViewModel
        self.fetcherViewModel = fetcherViewModel
        self.viewControllerFactory = viewControllerFactory
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("\(#function) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupChilds()
        setupBindings()
    }
}

// MARK: UISearchBarDelegate
extension MainViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        selectRepositoryViewModel.searchedText = searchBar.text
        searchController.dismiss(animated: true, completion: nil)
    }
}

// MARK: Private APIs
private extension MainViewController {
    func setupChilds() {
        embedChild(resultsVC)
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
    }

    func setupBindings() {
        fetcherViewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak resultsVC] isLoading in
                guard let refreshControl = resultsVC?.refreshControl
                else { return }

                if isLoading {
                    refreshControl.beginRefreshing()
                } else {
                    refreshControl.endRefreshing()
                }
            }
            .store(in: &subscriptions)

        fetcherViewModel.$error
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                if let error = $0 {
                    self?.showError(error)
                }
            }
            .store(in: &subscriptions)

        fetcherViewModel.$stargazers
            .receive(on: DispatchQueue.main)
            .sink { [weak resultsVC] in
                resultsVC?.items = $0 ?? []
            }
            .store(in: &subscriptions)

        selectRepositoryViewModel.$error
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                if let error = $0 {
                    self?.showError(error)
                }
            }
            .store(in: &subscriptions)

        selectRepositoryViewModel.$selectedRepository
            .assign(to: &fetcherViewModel.$selectedRepository)
    }

    func configureSearchBar(_ searchBar: UISearchBar) {
        searchBar.placeholder = NSLocalizedString(
            "search_repo_placeholder",
            comment: "Search repository placeholder"
        )
        searchBar.searchTextField.autocapitalizationType = .none
        searchBar.returnKeyType = .done
        searchBar.delegate = self
    }
}

// MARK: Private Refresh APIs
private extension MainViewController {
    @objc func refresh(sender: Any?) {
        fetcherViewModel.refreshStargazers()
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
