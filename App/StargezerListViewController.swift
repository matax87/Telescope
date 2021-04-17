//
//  StargezerListViewController.swift
//  Stargazers
//
//  Created by Matteo Matassoni on 14/04/2021.
//

import UIKit
import Combine
import ViewModels
import StargazerApiClient

class StargezersController: UIViewController {
    let viewModel: StargazerListViewModel

    weak var coordinator: StargazerListCoordinator?

    private var subscriptions: Set<AnyCancellable> = []

    private var dataSource: UICollectionViewDiffableDataSource<Section, Stargazer>! = nil
    private var currentSnapshot: NSDiffableDataSourceSnapshot<Section, Stargazer>! = nil
    private var collectionView: UICollectionView! = nil
    private lazy var formatter: RelativeDateTimeFormatter = { formatter in
        formatter.dateTimeStyle = .named
        formatter.formattingContext = .beginningOfSentence
        return formatter
    }(RelativeDateTimeFormatter())

    // MARK: Initalization
    init(viewModel: StargazerListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("\(#function) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        configureHierarchy()
        configureDataSource()
        setupBindings()
    }
}

// MARK: UIScrollViewDelegate
extension StargezersController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height

        if offsetY > contentHeight - scrollView.frame.height {
            //viewModel.fetchStargazers(ofRepository: repository)
        }
    }
}

// MARK: Private APIS
private extension StargezersController {
    private func setupBindings() {
        viewModel.loadingPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] in
                self?.updateUI(isLoading: $0)
            })
            .store(in: &subscriptions)

        viewModel.errorPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                print(error.localizedDescription)
            }.store(in: &subscriptions)

        viewModel.stargazersPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.updateUI(stargazer: $0, animated: true)
            }
            .store(in: &subscriptions)

    }

    enum Section {
        case main
    }

    func columnCount(for layoutEnviroment: NSCollectionLayoutEnvironment) -> Int {
        switch layoutEnviroment.container.effectiveContentSize.width {
        case 0..<300:
            return 1
        case 300..<500:
            return 2
        default:
            return 3
        }
    }

    func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout {
            (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            let columns = self.columnCount(for: layoutEnvironment)

            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(0.2),

                heightDimension: .fractionalHeight(1.0)
            )
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = NSDirectionalEdgeInsets(
                top: 2,
                leading: 2,
                bottom: 2,
                trailing: 2
            )

            let groupHeight: NSCollectionLayoutDimension = .estimated(112)
            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: groupHeight
            )
            let group = NSCollectionLayoutGroup.horizontal(
                layoutSize: groupSize,
                subitem: item,
                count: columns
            )

            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = NSDirectionalEdgeInsets(
                top: 5,
                leading: 5,
                bottom: 5,
                trailing: 5
            )
            return section
        }
        return layout
    }

    func configureDataSource() {
        let cellNib = UINib(
            nibName: String(describing: Cell.self),
            bundle: Bundle(for: Cell.self)
        )
        let cellRegistration: UICollectionView.CellRegistration<Cell, Stargazer>
        cellRegistration = .init(cellNib: cellNib) { cell, indexPath, stargazer in
            // Populate the cell with our item description.
            cell.textLabel?.text = stargazer.user.login
            cell.detailTextLabel?.text = self.formatter.localizedString(
                for: stargazer.starredAt,
                relativeTo: Date()
            )
        }

        dataSource = UICollectionViewDiffableDataSource<Section, Stargazer>(collectionView: collectionView) {
            (collectionView: UICollectionView, indexPath: IndexPath, stargazer: Stargazer) -> UICollectionViewCell? in
            collectionView.dequeueConfiguredReusableCell(
                using: cellRegistration,
                for: indexPath,
                item: stargazer
            )
        }
    }

    func configureHierarchy() {
        collectionView = UICollectionView(
            frame: view.bounds,
            collectionViewLayout: createLayout(
            ))
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .systemBackground
        collectionView.refreshControl = UIRefreshControl()
        view.addSubview(collectionView)
    }

    func updateUI(isLoading: Bool) {
        if isLoading {
            collectionView.refreshControl?.beginRefreshing()
        } else {
            collectionView.refreshControl?.endRefreshing()
        }
    }

    func updateUI(stargazer: [Stargazer], animated: Bool) {
        currentSnapshot = NSDiffableDataSourceSnapshot<Section, Stargazer>()

        currentSnapshot.appendSections([.main])
        currentSnapshot.appendItems(stargazer, toSection: .main)

        dataSource.apply(currentSnapshot, animatingDifferences: animated)
    }
}

