//
//  ServiceFactory.swift
//  Telescope
//
//  Created by Matteo Matassoni on 16/04/2021.
//

import Foundation
import ImageFetcher
import StargazerApiClient

protocol ServiceFactory {
    func makeStargazerApiClient() -> StargazerApiClientType
    func makeImageFetcher() -> ImageFetcherType
}
