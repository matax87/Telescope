//
//  ViewController.swift
//  Stargazers
//
//  Created by Matteo Matassoni on 14/04/2021.
//

import UIKit
import Model

class StargezerListViewController: UICollectionViewController {
    private var dataSource: UICollectionViewDiffableDataSource<Section, Stargazer>! = nil
    private var currentSnapshot: NSDiffableDataSourceSnapshot<Section, Stargazer>! = nil

    private lazy var model: Model = Model(networkService: URLSession.shared)

    override func viewDidLoad() {
        super.viewDidLoad()

        let repository = Repository(owner: "octocat", name: "Hello-World")
        model.fetchStagazerList(of: repository) { [weak self] result in
            self?.handle(result)
        }
    }
}

private extension StargezerListViewController {
    enum Section {
        case main
    }

    func columnCount(for width: CGFloat) -> Int {
        let wideMode = width > 800
        return wideMode ? 5 : 3
    }

    func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout {
            (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            let columns = self.columnCount(for: layoutEnvironment.container.effectiveContentSize.width)

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

            let groupHeight: NSCollectionLayoutDimension = .fractionalWidth(0.2)
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
                top: 20,
                leading: 20,
                bottom: 20,
                trailing: 20
            )
            return section
        }
        return layout
    }

    func configureDataSource() {
        let cellRegistration = UICollectionView.CellRegistration<Cell, Stargazer> { cell, indexPath, stargazer in
            // Populate the cell with our item description.
            cell.textLabel?.text = stargazer.user.login
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

    func handle(_ result: Result<Stargazer.NetworkResponse, Error>) {
        switch result {
        case .success(let stargazer):
            updateUI(with: stargazer.items, animated: true)
        case .failure(let error):
            print(error.localizedDescription)
        }
    }

    func updateUI(with stargazer: [Stargazer], animated: Bool) {
        currentSnapshot = NSDiffableDataSourceSnapshot<Section, Stargazer>()

        currentSnapshot.appendSections([.main])
        currentSnapshot.appendItems(stargazer, toSection: .main)

        dataSource.apply(currentSnapshot, animatingDifferences: animated)
    }
}

