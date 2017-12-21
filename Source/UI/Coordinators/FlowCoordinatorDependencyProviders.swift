//
//  FlowCoordinatorDependencyProviders.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 15/05/2017.
//  Copyright © 2017 Maksym Shcheglov. All rights reserved.
//

import UIKit

/// The `ApplicationFlowCoordinatorDependencyProvider` protocol defines methods to satisfy external dependencies of the ApplicationFlowCoordinator
protocol ApplicationFlowCoordinatorDependencyProvider: class {
    /// Creates UITabBarController
    func tabBarController() -> UITabBarController
}

protocol SearchFlowCoordinatorDependencyProvider: class {
    /// Creates SessionsSearchViewController to browse and search WWDC sessions
    func sessionsSearchController(delegate: SessionsSearchViewModelDelegate, previewProvider: TableViewControllerPreviewProvider) -> UIViewController

    // Creates SessionDetailsViewController to show the details of the session with specified identifier
    func sessionDetailsController(_ sessionId: String) -> UIViewController

    // Creates FilterViewController to filter the search results
    func filterController(_ filter: Filter, completion: @escaping FilterViewModelCompletion) -> UIViewController
}

protocol FavoritesFlowCoordinatorDependencyProvider: class {
    /// Creates FavoriteSessionsViewController to browse favorite sessions
    func favoriteSessionsController(navigator: FavoriteSessionsNavigator, previewProvider: TableViewControllerPreviewProvider) -> UIViewController

    // Creates SessionDetailsViewController to show the details of the session with specified identifier
    func sessionDetailsController(_ sessionId: String) -> UIViewController
}
