//
//  ApplicationFlowCoordinator.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 18/02/2017.
//  Copyright © 2017 Maksym Shcheglov. All rights reserved.
//

import UIKit

/// The application flow coordinator. Takes responsibility about coordinating view controllers and driving the flow
class ApplicationFlowCoordinator: FlowCoordinator {

    typealias DependencyProvider = ApplicationFlowCoordinatorDependencyProvider & SearchFlowCoordinatorDependencyProvider & FavoritesFlowCoordinatorDependencyProvider

    private let window: UIWindow
    private let dependencyProvider: DependencyProvider
    private var childCoordinators = [FlowCoordinator]()

    init(window: UIWindow, dependencyProvider: DependencyProvider) {
        self.window = window
        self.dependencyProvider = dependencyProvider
    }

    /// Creates all necessary dependencies and starts the flow
    func start() {

        let searchNavigationController = UINavigationController()
        searchNavigationController.navigationBar.tintColor = UIColor.black
        searchNavigationController.tabBarItem = UITabBarItem(tabBarSystemItem: .search, tag: 0)

        let favoritesNavigationController = UINavigationController()
        favoritesNavigationController.navigationBar.tintColor = UIColor.black
        favoritesNavigationController.tabBarItem = UITabBarItem(tabBarSystemItem: .favorites, tag: 1)

        let tabBarController = self.dependencyProvider.tabBarController()
        tabBarController.viewControllers = [searchNavigationController, favoritesNavigationController]
        self.window.rootViewController = tabBarController

        let searchFlowCoordinator = SearchFlowCoordinator(rootController: searchNavigationController, dependencyProvider: self.dependencyProvider)
        searchFlowCoordinator.start()

        let favoritesFlowCoordinator = FavoritesFlowCoordinator(rootController: favoritesNavigationController, dependencyProvider: self.dependencyProvider)
        favoritesFlowCoordinator.start()

        self.childCoordinators = [searchFlowCoordinator, favoritesFlowCoordinator]
    }

}
