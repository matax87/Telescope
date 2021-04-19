//
//  Coordinator.swift
//  Telescope
//
//  Created by Matteo Matassoni on 16/04/2021.
//

import UIKit

/// Coordinator protocol. Coordinators are responsible to handle navigations and object creations.
protocol Coordinator: AnyObject {
    typealias DependencyRepresentable = ViewModelFactory & ViewControllerFactory

    /// childCoordinators: child coordinators should be append to this array to keep them alive!
    var childCoordinators: [Coordinator] { get set }

    /// Since main task of  coordinators is handling navigation, they directly interract with navigation controllers
    var navigationController: UINavigationController { get set }

    /// Coordinators need container for creating view controllers
    var dependencyContainer: DependencyRepresentable { get set }

    /// Start function triggers view controller creation and navigations.
    func start(animated: Bool)
}
