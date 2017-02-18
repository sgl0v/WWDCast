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

    private let window: UIWindow
    private let factory: ViewControllerFactoryProtocol
    private var childCoordinators = [FlowCoordinator]()

    init(window: UIWindow, factory: ViewControllerFactoryProtocol) {
        self.window = window
        self.factory = factory
    }

    /// Creates all necessary dependencies and starts the flow
    func start() {

        let searchNavigationController = UINavigationController()
        searchNavigationController.navigationBar.tintColor = UIColor.black
        searchNavigationController.tabBarItem = UITabBarItem(tabBarSystemItem: .search, tag: 0)

        let favoritesNavigationController = UINavigationController()
        favoritesNavigationController.navigationBar.tintColor = UIColor.black
        favoritesNavigationController.tabBarItem = UITabBarItem(tabBarSystemItem: .favorites, tag: 1)

        let tabBarController = self.factory.tabBarController()
        tabBarController.viewControllers = [searchNavigationController, favoritesNavigationController]
        self.window.rootViewController = tabBarController

        let searchFlowCoordinator = SearchFlowCoordinator(rootController: searchNavigationController, factory: self.factory)
        searchFlowCoordinator.start()

        let favoritesFlowCoordinator = FavoritesFlowCoordinator(rootController: favoritesNavigationController, factory: self.factory)
        favoritesFlowCoordinator.start()

        self.childCoordinators = [searchFlowCoordinator, favoritesFlowCoordinator]
    }

}
