//
//  ViewControllerFactoryMock.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 18/02/2017.
//  Copyright © 2017 Maksym Shcheglov. All rights reserved.
//

import UIKit
@testable import WWDCast

class MockApplicationComponentsFactory {
    typealias TabBarHandler = () -> UITabBarController
    typealias SearchHandler = (SessionsSearchNavigator,  TableViewControllerPreviewProvider) -> UIViewController
    typealias FavoritesHandler = (FavoriteSessionsNavigator,  TableViewControllerPreviewProvider) -> UIViewController
    typealias DetailsHandler = (String) -> UIViewController
    typealias FilterHandler = () -> UIViewController

    var tabBarHandler: TabBarHandler?
    var searchHandler: SearchHandler?
    var favoritesHandler: FavoritesHandler?
    var detailsHandler: DetailsHandler?
    var filterHandler: FilterHandler?
}

extension MockApplicationComponentsFactory: ApplicationFlowCoordinatorDependencyProvider {

    func tabBarController() -> UITabBarController {
        guard let handler = self.tabBarHandler else {
            fatalError("Not implemented")
        }
        return handler()
    }

}

extension MockApplicationComponentsFactory: SearchFlowCoordinatorDependencyProvider, FavoritesFlowCoordinatorDependencyProvider {

    func sessionsSearchController(navigator: SessionsSearchNavigator, previewProvider: TableViewControllerPreviewProvider) -> UIViewController {
        guard let handler = self.searchHandler else {
            fatalError("Not implemented")
        }
        return handler(navigator, previewProvider)
    }

    func favoriteSessionsController(navigator: FavoriteSessionsNavigator, previewProvider: TableViewControllerPreviewProvider) -> UIViewController {
        guard let handler = self.favoritesHandler else {
            fatalError("Not implemented")
        }
        return handler(navigator, previewProvider)
    }

    func sessionDetailsController(_ sessionId: String) -> UIViewController {
        guard let handler = self.detailsHandler else {
            fatalError("Not implemented")
        }
        return handler(sessionId)
    }

    func filterController(navigator: FilterNavigator) -> UIViewController {
        guard let handler = self.filterHandler else {
            fatalError("Not implemented")
        }
        return handler()
    }
}

