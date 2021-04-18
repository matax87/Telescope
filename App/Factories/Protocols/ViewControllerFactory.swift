//
//  ViewControllerFactory.swift
//  Telescope
//
//  Created by Matteo Matassoni on 16/04/2021.
//

import Foundation

protocol ViewControllerFactory {
    func makeMainViewController() -> MainViewController
    func makeListViewController() -> ListViewController
}
