//
//  SessionsSearchWireframeImpl.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 04/07/16.
//  Copyright © 2016 Maksym Shcheglov. All rights reserved.
//

import UIKit

class WWDCastAssemblyImpl: WWDCastAssembly {

    lazy var api: WWDCastAPI = {
        let serviceProvider = ServiceProviderImpl.defaultServiceProvider
        return WWDCastAPIImpl(serviceProvider: serviceProvider)
    }()

    func tabBarController(delegate: SessionsSearchDelegate & FavoriteSessionsDelegate) -> UIViewController {
        let sessionsSearchController = self.sessionsSearchController(delegate: delegate)
        sessionsSearchController.tabBarItem = UITabBarItem(tabBarSystemItem: .search, tag: 0)
        let favoriteSessionsController = self.favoriteSessionsController(delegate: delegate)
        favoriteSessionsController.tabBarItem = UITabBarItem(tabBarSystemItem: .favorites, tag: 1)
        let tabbarController = TabBarController()
        tabbarController.tabBar.tintColor = UIColor.black
        tabbarController.viewControllers = [sessionsSearchController, favoriteSessionsController]
        return tabbarController
    }

    func sessionsSearchController(delegate: SessionsSearchDelegate) -> UIViewController {
        let viewModel = SessionsSearchViewModelImpl(api: self.api, delegate: delegate)
        let view = SessionsSearchViewController(viewModel: viewModel)
        view.previewProvider = self
        let navigationController = UINavigationController(rootViewController: view)
        navigationController.navigationBar.tintColor = UIColor.black
        return navigationController
    }

    func filterController(_ filter: Filter, completion: @escaping FilterModuleCompletion) -> UIViewController {
        let viewModel = FilterViewModelImpl(filter: filter, completion: completion)
        let view = FilterViewController(viewModel: viewModel)
        let navigationController = UINavigationController(rootViewController: view)
        navigationController.navigationBar.tintColor = UIColor.black
        return navigationController
    }

    func sessionDetailsController(_ sessionId: String) -> UIViewController {
        let viewModel = SessionDetailsViewModelImpl(sessionId: sessionId, api: self.api)
        return SessionDetailsViewController(viewModel: viewModel)
    }

    func favoriteSessionsController(delegate: FavoriteSessionsDelegate) -> UIViewController {
        let viewModel = FavoriteSessionsViewModelImpl(api: self.api, delegate: delegate)
        let view = FavoriteSessionsViewController(viewModel: viewModel)
        view.previewProvider = self
        let navigationController = UINavigationController(rootViewController: view)
        navigationController.navigationBar.tintColor = UIColor.black
        return navigationController
    }

}

extension WWDCastAssemblyImpl: TableViewControllerPreviewProvider {
    func previewController<Item>(forItem item: Item) -> UIViewController? {
        guard let item = item as? SessionItemViewModel else {
            return nil
        }
        return sessionDetailsController(item.uniqueID)
    }
}
