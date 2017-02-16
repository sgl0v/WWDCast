//
//  ModuleFactory.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 06/07/16.
//  Copyright © 2016 Maksym Shcheglov. All rights reserved.
//

import UIKit

/// The WWDCastAssembly protocol defines factory methods to create MVVM modules
protocol WWDCastAssembly: class {

    /// Creates UITabBarController
    func tabBarController() -> UITabBarController

    /// Creates SessionsSearchViewController to browse and search WWDC sessions
    func sessionsSearchController(delegate: SessionsSearchViewModelDelegate, previewProvider: TableViewControllerPreviewProvider) -> UIViewController

    /// Creates FavoriteSessionsViewController to browse favorite sessions
    func favoriteSessionsController(delegate: FavoriteSessionsViewModelDelegate, previewProvider: TableViewControllerPreviewProvider) -> UIViewController

    // Creates SessionDetailsViewController to show the details of the session with specified identifier
    func sessionDetailsController(_ sessionId: String) -> UIViewController

    // Creates FilterViewController to filter the search results
    func filterController(_ filter: Filter, completion: @escaping FilterModuleCompletion) -> UIViewController
}
