//
//  ViewModelFactory.swift
//  Telescope
//
//  Created by Matteo Matassoni on 16/04/2021.
//

import Foundation
import ViewModels

protocol ViewModelFactory {
    func makeFetcherViewModel() -> FetcherViewModel
    func makeSelectRepositoryViewModel() -> SelectRepositoryViewModel
}
