//
//  MainCoordinator.swift
//  Telescope
//
//  Created by Matteo Matassoni on 16/04/2021.
//

import UIKit

final class MainCoordinator: BaseCoordinator {
    override func start(animated: Bool) {
        let mainVC = dependencyContainer.makeMainViewController()        
        mainVC.coordinator = self
        mainVC.title = NSLocalizedString("Telescope", comment: "App name")

        navigationController.pushViewController(
            mainVC,
            animated: animated
        )
    }
}
