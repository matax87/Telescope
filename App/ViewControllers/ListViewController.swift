//
//  ListViewController.swift
//  Stargazers
//
//  Created by Matteo Matassoni on 16/04/2021.
//

import UIKit
import StargazerApiClient
import ImageFetcher

class ListViewController: UIViewController {
    private var dataSource: UICollectionViewDiffableDataSource<Section, Stargazer>! = nil
    private var currentSnapshot: NSDiffableDataSourceSnapshot<Section, Stargazer>! = nil
    private var collectionView: UICollectionView! = nil

    var items: [Stargazer] = [] {
        didSet {
            guard isViewLoaded
            else { return }

            let animated = view.window != nil
            updateUI(stargazer: items, animated: animated)
        }
    }
    
    var refreshControl = UIRefreshControl()

    var imageFetcher: ImageFetcherType!

    var scrollViewDidScrollHandler: ((UIScrollView) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()

        configureViewHierarchy()
        configureDataSource()
        updateUI(stargazer: items, animated: false)
    }
}

// MARK: UICollectionViewDelegate
extension ListViewController: UICollectionViewDelegate {
    // MARK: UIScrollViewDelegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollViewDidScrollHandler?(scrollView)
    }
}

// MARK: Private APIs
private extension ListViewController {
    typealias Cell = UIIdentificableCollectionViewCell<URL>

    static let defaultImage = UIImage(
        systemName: "person.circle.fill",
        withConfiguration: UIImage.SymbolConfiguration(pointSize: 500)
    )

    enum Section {
        case main
    }

    func downloadThenSetAvatar(
        cell: UICollectionViewCell,
        at indexPath: IndexPath
    ) {
        guard
            let idCell = cell as? UIIdentificableCollectionViewCell<URL>,
            let imageLoader = imageFetcher,
            let imageURL = self.imageURL(at: indexPath)
        else { return }

        imageLoader.fetchImage(fromUrl: imageURL) { result in
            guard
                case let .success(image) = result,
                idCell.id == imageURL,
                let contentConfiguration = cell.contentConfiguration as? UIListContentConfiguration
            else { return }

            var mutableCopy = contentConfiguration
            mutableCopy.image = image
            cell.contentConfiguration = mutableCopy
        }
    }

    func columnCount(for layoutEnviroment: NSCollectionLayoutEnvironment) -> Int {
        switch layoutEnviroment.container.effectiveContentSize.width {
        case 0..<600:
            return 1
        default:
            return 2
        }
    }

    func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { sectionIndex, layoutEnvironment in
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

            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(60)
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
        let cellRegistration: UICollectionView.CellRegistration<Cell, Stargazer>
        cellRegistration = .init() { cell, indexPath, stargazer in
            let imageURLOrNil = self.imageURL(at: indexPath)
            cell.id = imageURLOrNil

            var content = UIListContentConfiguration.cell()
            content.text = stargazer.user.login
            content.textProperties.font = .preferredFont(forTextStyle: .title3)
            content.textProperties.numberOfLines = 0
            content.image = Self.defaultImage
            content.imageProperties.tintColor = .tertiaryLabel
            content.imageProperties.cornerRadius = 22
            content.imageProperties.reservedLayoutSize = CGSize(width: 44, height: 44)
            content.imageProperties.maximumSize = content.imageProperties.reservedLayoutSize
            if let imageURL = imageURLOrNil,
               let image = self.imageFetcher[imageURL] {
                content.image = image
            } else {
                self.downloadThenSetAvatar(cell: cell, at: indexPath)
            }
            cell.contentConfiguration = content

            var background = UIBackgroundConfiguration.listPlainCell()
            background.cornerRadius = 8
            background.strokeColor = .systemGray3
            background.strokeWidth = 1.0 / cell.traitCollection.displayScale
            cell.backgroundConfiguration = background
        }

        dataSource = .init(
            collectionView: collectionView
        ) { collectionView, indexPath, stargazer in
            collectionView.dequeueConfiguredReusableCell(
                using: cellRegistration,
                for: indexPath,
                item: stargazer
            )
        }
    }

    func configureViewHierarchy() {
        collectionView = UICollectionView(
            frame: view.bounds,
            collectionViewLayout: createLayout(
            ))
        collectionView.autoresizingMask = [
            .flexibleWidth,
            .flexibleHeight
        ]
        view.addSubview(collectionView)

        collectionView.backgroundColor = .systemBackground
        collectionView.refreshControl = refreshControl
        collectionView.delegate = self
        collectionView.prefetchDataSource = self
    }

    func updateUI(stargazer: [Stargazer], animated: Bool) {
        currentSnapshot = NSDiffableDataSourceSnapshot<Section, Stargazer>()

        currentSnapshot.appendSections([.main])
        currentSnapshot.appendItems(stargazer, toSection: .main)

        dataSource.apply(currentSnapshot, animatingDifferences: animated)
    }

    func imageURL(at indexPath: IndexPath) -> URL? {
        guard let imageURLString = dataSource.itemIdentifier(for: indexPath)?
                .user
                .avatarUrl
        else { return nil }

        return URL(string: imageURLString)
    }

    func imageURLs(at indexPaths: [IndexPath]) -> [URL] {
        indexPaths
            .map { self.imageURL(at: $0) }
            .compactMap { $0 }
    }
}

extension ListViewController: UICollectionViewDataSourcePrefetching {
    func collectionView(
        _ collectionView: UICollectionView,
        prefetchItemsAt indexPaths: [IndexPath]
    ) {
        imageURLs(at: indexPaths)
            .forEach {
                imageFetcher.fetchImage(
                    fromUrl: $0,
                    completionHandler: nil
                )
            }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cancelPrefetchingForItemsAt indexPaths: [IndexPath]
    ) {
        imageURLs(at: indexPaths)
            .forEach { imageFetcher.cancelFetching(fromUrl: $0) }
    }
}

private class UIIdentificableCollectionViewCell<T>:
    UICollectionViewCell,
    Identifiable
{
    var id: T!

    override func prepareForReuse() {
        super.prepareForReuse()
        id = nil
    }
}
