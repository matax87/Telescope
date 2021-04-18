//
//  AppCoordinator.swift
//  Telescope
//
//  Created by Matteo Matassoni on 16/04/2021.
//

import UIKit

final class AppCoordinator: BaseCoordinator {
    override func start(animated: Bool) {
        let mainCoordinator = MainCoordinator(
            navigationController: navigationController,
            dependencyContainer: dependencyContainer
        )
        childCoordinators.append(mainCoordinator)
        mainCoordinator.start(animated: animated)
    }
}
