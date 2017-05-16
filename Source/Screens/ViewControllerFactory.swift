//
//  SessionsSearchWireframeImpl.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 04/07/16.
//  Copyright © 2016 Maksym Shcheglov. All rights reserved.
//

import UIKit

class ViewControllerFactory {

    fileprivate let api: WWDCastAPIProtocol = WWDCastAPI(serviceProvider: ServiceProvider.defaultServiceProviderProtocol)

}

extension ViewControllerFactory: ApplicationFlowCoordinatorDependencyProvider {

    func tabBarController() -> UITabBarController {
        let tabbarController = TabBarController()
        tabbarController.tabBar.tintColor = UIColor.black
        return tabbarController
    }

}

extension ViewControllerFactory: SearchFlowCoordinatorDependencyProvider {

    func sessionsSearchController(delegate: SessionsSearchViewModelDelegate, previewProvider: TableViewControllerPreviewProvider) -> UIViewController {
        let viewModel = SessionsSearchViewModel(api: self.api, delegate: delegate)
        let view = SessionsSearchViewController(viewModel: viewModel)
        view.previewProvider = previewProvider
        return view
    }

    func sessionDetailsController(_ sessionId: String) -> UIViewController {
        let viewModel = SessionDetailsViewModel(sessionId: sessionId, api: self.api)
        return SessionDetailsViewController(viewModel: viewModel)
    }

    func filterController(_ filter: Filter, completion: @escaping FilterViewModelCompletion) -> UIViewController {
        let viewModel = FilterViewModel(filter: filter, completion: completion)
        let view = FilterViewController(viewModel: viewModel)
        let navigationController = UINavigationController(rootViewController: view)
        navigationController.navigationBar.tintColor = UIColor.black
        return navigationController
    }

}

extension ViewControllerFactory: FavoritesFlowCoordinatorDependencyProvider {

    func favoriteSessionsController(delegate: FavoriteSessionsViewModelDelegate, previewProvider: TableViewControllerPreviewProvider) -> UIViewController {
        let viewModel = FavoriteSessionsViewModel(api: self.api, delegate: delegate)
        let view =  FavoriteSessionsViewController(viewModel: viewModel)
        view.previewProvider = previewProvider
        return view
    }

}
