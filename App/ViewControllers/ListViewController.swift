//
//  ListViewController.swift
//  Items
//
//  Created by Matteo Matassoni on 16/04/2021.
//

import UIKit
import StargazerApiClient
import ImageFetcher

// MARK: - ListViewController
class ListViewController: UIViewController {
    private var dataSource: UICollectionViewDiffableDataSource<Section, Item>! = nil
    private var currentSnapshot: NSDiffableDataSourceSnapshot<Section, Item>! = nil
    private var collectionView: UICollectionView! = nil

    typealias Item = Stargazer
    
    var items: [Item] = [] {
        didSet {
            guard isViewLoaded
            else { return }

            let animated = view.window != nil
            updateUI(items: items, animated: animated)
        }
    }
    
    var refreshControl = UIRefreshControl()

    var imageFetcher: ImageFetcherType!

    var willDisplayLastItemHandler: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()

        configureViewHierarchy()
        configureDataSource()
        updateUI(items: items, animated: false)
    }
}

// MARK: UICollectionViewDelegate
extension ListViewController: UICollectionViewDelegate {
    func collectionView(
        _ collectionView: UICollectionView,
        willDisplay cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        if
            let lastItem = items.last,
            let lastItemIndexPath = dataSource.indexPath(for: lastItem),
            indexPath == lastItemIndexPath {
            willDisplayLastItemHandler?()
        }
    }
}

// MARK: Private APIs
private extension ListViewController {
    typealias ListCell = UIIdentifiableCollectionViewListCell<URL>

    static let defaultImage = UIImage(
        systemName: "person.circle.fill",
        withConfiguration: UIImage.SymbolConfiguration(pointSize: 500)
    )

    enum Section {
        case main
    }

    func downloadThenSetImage(
        cell: UICollectionViewCell,
        at indexPath: IndexPath
    ) {
        guard
            let idCell = cell as? UIIdentifiableCollectionViewListCell<URL>,
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
        UICollectionViewCompositionalLayout { sectionIndex, layoutEnvironment in
            NSCollectionLayoutSection.list(
                using: .init(appearance: .plain),
                layoutEnvironment: layoutEnvironment
            )
        }
    }

    func configureDataSource() {
        let cellRegistration: UICollectionView.CellRegistration<ListCell, Item>
        cellRegistration = .init() { cell, indexPath, item in
            let imageURLOrNil = self.imageURL(at: indexPath)
            cell.id = imageURLOrNil

            var content = cell.defaultContentConfiguration()
            content.text = item.user.login
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
                self.downloadThenSetImage(cell: cell, at: indexPath)
            }
            cell.contentConfiguration = content
        }

        dataSource = .init(
            collectionView: collectionView
        ) { collectionView, indexPath, item in
            collectionView.dequeueConfiguredReusableCell(
                using: cellRegistration,
                for: indexPath,
                item: item
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

    func updateUI(items: [Item], animated: Bool) {
        currentSnapshot = NSDiffableDataSourceSnapshot<Section, Item>()

        currentSnapshot.appendSections([.main])
        currentSnapshot.appendItems(items, toSection: .main)

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

// MARK: UICollectionViewDataSourcePrefetching
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

// MARK: - UIIdentifiableCollectionViewListCell
private class UIIdentifiableCollectionViewListCell<T>:
    UICollectionViewListCell,
    Identifiable
{
    var id: T!

    override func prepareForReuse() {
        super.prepareForReuse()
        id = nil
    }
}
