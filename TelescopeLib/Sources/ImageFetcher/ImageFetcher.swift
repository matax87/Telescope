//
//  ImageFetcher.swift
//  NetworkToolbox
//
//  Created by Matteo Matassoni on 17/04/2021.
//

import UIKit
import SwiftCache
import NetworkToolbox

// MARK: - ImageFetcherError
private enum ImageFetcherError: Error {
    case invalidData(Data?)
}

// MARK: - ImageFetcherHandler
public typealias ImageFetcherHandler = (Result<UIImage, Error>) -> Void

// MARK: - ImageFetcherHandler
public typealias ImageProcessor = (UIImage) -> UIImage

// MARK: - ImageFetcherType
public protocol ImageFetcherType {
    subscript(url: URL) -> UIImage? { get }
    
    subscript(
        url: URL,
        default defaultImage: @autoclosure () -> UIImage
    ) -> UIImage { get }
    
    func fetchImage(
        fromUrl url: URL,
        processing: ImageProcessor?,
        completionQueue: DispatchQueue,
        completionHandler: ImageFetcherHandler?
    )
    
    func cancelFetching(fromUrl url: URL)
}

// MARK: Defaults
extension ImageFetcherType {
    public func fetchImage(
        fromUrl url: URL,
        processing: ImageProcessor? = nil,
        completionQueue: DispatchQueue = .main,
        completionHandler: ImageFetcherHandler?
    ) {
        fetchImage(
            fromUrl: url,
            processing: processing,
            completionQueue: completionQueue,
            completionHandler: completionHandler
        )
    }
}

// MARK: - ImageFetcher
public final class ImageFetcher: ImageFetcherType {
    let networkService: NetworkService
    // Queue to sync up its internal state (thread-safeness)
    let internalQueue: DispatchQueue
    let imageProccessingQueue: DispatchQueue
    
    private var urlToDownloadedImage: Cache<URL, UIImage> = Cache()
    private var urlToPendingHandlers: [URL: [ImageFetcherHandler]] = [:]
    private var urlToPendingTask: [URL: NTBCancellable] = [:]
    
    public init(
        networkService: NetworkService,
        internalQueue: DispatchQueue = .init(label: "ImageFetcher"),
        imageProccessingQueue: DispatchQueue = .init(label: "ImageFetcher-Processing")
    ) {
        self.networkService = networkService
            .checkingStatusCodes()
        self.internalQueue = internalQueue
        self.imageProccessingQueue = imageProccessingQueue
    }
    
    public subscript(url: URL) -> UIImage? {
        get {
            urlToDownloadedImage[url]
        }
    }
    
    public subscript(
        url: URL,
        default defaultImage: @autoclosure () -> UIImage
    ) -> UIImage {
        get {
            self[url] ?? defaultImage()
        }
    }
    
    public func fetchImage(
        fromUrl url: URL,
        processing: ImageProcessor?,
        completionQueue: DispatchQueue,
        completionHandler: ImageFetcherHandler?
    ) {
        internalQueue.async { [weak self] in
            self?.performFetchImage(
                fromUrl: url,
                processing: processing,
                completionQueue: completionQueue,
                completionHandler: completionHandler ?? { _ in }
            )
        }
    }
    
    public func cancelFetching(fromUrl url: URL) {
        guard let task = urlToPendingTask[url]
        else { return }
        
        task.cancel()
    }
}

// MARK: Private APIs
private extension ImageFetcher {
    func handle(
        _ result: Result<UIImage, Error>,
        originalUrl url: URL,
        completionQueue: DispatchQueue
    ) {
        guard let handlers = urlToPendingHandlers[url]
        else { return }

        urlToPendingTask[url] = nil
        urlToDownloadedImage[url] = try? result.get()
        urlToPendingHandlers[url] = []

        handlers.forEach { handler in
            completionQueue.async {
                handler(result)
            }
        }
    }

    func performFetchImage(
        fromUrl url: URL,
        processing: ImageProcessor?,
        completionQueue: DispatchQueue,
        completionHandler: @escaping ImageFetcherHandler
    ) {
        let availableImageOrNil = urlToDownloadedImage[url]
        guard availableImageOrNil == nil
        else { return completionHandler(.success(availableImageOrNil!)) }
        
        var pendingHandlers = urlToPendingHandlers[url] ?? []
        pendingHandlers.append(completionHandler)
        urlToPendingHandlers[url] = pendingHandlers
        
        guard pendingHandlers.count == 1
        else { return }
        
        let request = URLRequest(url: url)
        let task = networkService
            .fetchData(with: request) { [weak self] data, response, error in
                let result: Result<UIImage, Error>
                switch (data, error) {
                case let (_, error?):
                    result = .failure(error)
                case let (data?, _):
                    if let image = UIImage(data: data) {
                        if let processing = processing {
                            result = .success(processing(image))
                        } else {
                            result = .success(image)
                        }
                    } else {
                        result = .failure(ImageFetcherError.invalidData(data))
                    }
                case (nil, nil):
                    result = .failure(ImageFetcherError.invalidData(nil))
                }
                // Whenever our internal state mutates we always dispatch onto
                // `queue`, in order to avoid concurrent mutations.
                self?.internalQueue.async {
                    self?.handle(
                        result,
                        originalUrl: url,
                        completionQueue: completionQueue
                    )
                }
            }
        urlToPendingTask[url] = task
    }
}
