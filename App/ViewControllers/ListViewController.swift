//
//  ListViewController.swift
//  Items
//
//  Created by Matteo Matassoni on 16/04/2021.
//

import ImageFetcher
import StargazerApiClient
import UIKit

// MARK: - ListSelectionResponse

struct ListSelectionResponse: OptionSet {
    let rawValue: Int

    init(rawValue: Int) {
        self.rawValue = rawValue
    }

    static let none = ListSelectionResponse([])
    static let deselect = ListSelectionResponse(rawValue: 1 << 0)
}

// MARK: - ListViewController

class ListViewController: UIViewController {
    private var dataSource: UICollectionViewDiffableDataSource<Section, Item>!
    private var currentSnapshot: NSDiffableDataSourceSnapshot<Section, Item>!
    private var collectionView: UICollectionView!

    typealias Item = Stargazer

    var items: [Item] = [] {
        didSet {
            guard isViewLoaded
            else { return }

            // Stop unneeded image fetching
            if let imageFetcher = imageFetcher {
                let oldImageURLs = Set(oldValue.map(\.user.avatarUrl))
                let newImageURLs = Set(items.map(\.user.avatarUrl))
                let uselessImageURLs =
                    oldImageURLs.subtracting(newImageURLs)
                        .compactMap(URL.init(string:))
                uselessImageURLs.forEach { uselessImageURL in
                    imageFetcher.cancelFetching(fromUrl: uselessImageURL)
                }
            }

            // Update items
            let animated = view.window != nil
            updateUI(items: items, animated: animated)
        }
    }

    var refreshControl = UIRefreshControl()

    var imageFetcher: ImageFetcherType!

    var didSelectItemHandler: ((Item) -> ListSelectionResponse?)?
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
        didSelectItemAt indexPath: IndexPath
    ) {
        guard let selectedItem = dataSource.itemIdentifier(for: indexPath)
        else { return }

        let response = didSelectItemHandler?(selectedItem) ?? [.deselect]
        if response.contains(.deselect) {
            collectionView.deselectItem(
                at: indexPath,
                animated: true
            )
        }
    }

    func collectionView(
        _: UICollectionView,
        willDisplay _: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        if
            let lastItem = items.last,
            let lastItemIndexPath = dataSource.indexPath(for: lastItem),
            indexPath == lastItemIndexPath
        {
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
        case 0 ..< 600:
            return 1
        default:
            return 2
        }
    }

    func createLayout() -> UICollectionViewLayout {
        UICollectionViewCompositionalLayout { _, layoutEnvironment in
            NSCollectionLayoutSection.list(
                using: .init(appearance: .plain),
                layoutEnvironment: layoutEnvironment
            )
        }
    }

    func configureDataSource() {
        let cellRegistration: UICollectionView.CellRegistration<ListCell, Item>
        cellRegistration = .init { cell, indexPath, item in
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
            )
        )
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
        _: UICollectionView,
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
        _: UICollectionView,
        cancelPrefetchingForItemsAt indexPaths: [IndexPath]
    ) {
        imageURLs(at: indexPaths)
            .forEach { imageFetcher.cancelFetching(fromUrl: $0) }
    }
}

// MARK: - UIIdentifiableCollectionViewListCell

private class UIIdentifiableCollectionViewListCell<T>: UICollectionViewListCell,
    Identifiable {
    var id: T!

    override func prepareForReuse() {
        super.prepareForReuse()
        id = nil
    }
}
