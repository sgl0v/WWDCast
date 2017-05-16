//
//  ViewControllerFactoryMock.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 18/02/2017.
//  Copyright © 2017 Maksym Shcheglov. All rights reserved.
//

import UIKit
@testable import WWDCast

class MockViewControllerFactory: ApplicationFlowCoordinatorDependencyProvider, SearchFlowCoordinatorDependencyProvider, FavoritesFlowCoordinatorDependencyProvider {

    typealias TabBarHandler = () -> UITabBarController
    typealias SearchHandler = (SessionsSearchViewModelDelegate,  TableViewControllerPreviewProvider) -> UIViewController
    typealias FavoritesHandler = (FavoriteSessionsViewModelDelegate,  TableViewControllerPreviewProvider) -> UIViewController
    typealias DetailsHandler = (String) -> UIViewController
    typealias FilterHandler = (Filter, @escaping FilterViewModelCompletion) -> UIViewController

    var tabBarHandler: TabBarHandler?
    var searchHandler: SearchHandler?
    var favoritesHandler: FavoritesHandler?
    var detailsHandler: DetailsHandler?
    var filterHandler: FilterHandler?

    func tabBarController() -> UITabBarController {
        guard let handler = self.tabBarHandler else {
            fatalError("Not implemented")
        }
        return handler()
    }

    func sessionsSearchController(delegate: SessionsSearchViewModelDelegate, previewProvider: TableViewControllerPreviewProvider) -> UIViewController {
        guard let handler = self.searchHandler else {
            fatalError("Not implemented")
        }
        return handler(delegate, previewProvider)
    }

    func favoriteSessionsController(delegate: FavoriteSessionsViewModelDelegate, previewProvider: TableViewControllerPreviewProvider) -> UIViewController {
        guard let handler = self.favoritesHandler else {
            fatalError("Not implemented")
        }
        return handler(delegate, previewProvider)
    }

    func sessionDetailsController(_ sessionId: String) -> UIViewController {
        guard let handler = self.detailsHandler else {
            fatalError("Not implemented")
        }
        return handler(sessionId)
    }

    func filterController(_ filter: Filter, completion: @escaping FilterViewModelCompletion) -> UIViewController {
        guard let handler = self.filterHandler else {
            fatalError("Not implemented")
        }
        return handler(filter, completion)
    }
}
