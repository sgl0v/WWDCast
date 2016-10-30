//
//  SessionsSearchWireframeImpl.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 04/07/16.
//  Copyright © 2016 Maksym Shcheglov. All rights reserved.
//

import UIKit

@objc class WWDCastAssemblyImpl: NSObject, WWDCastAssembly {
    
    lazy var router: WWDCastRouterImpl = {
        return WWDCastRouterImpl(moduleFactory: self)
    }()

    lazy var api: WWDCastAPI = {
        let serviceProvider = ServiceProviderImpl.defaultServiceProvider
        let cache = SessionsCacheImpl(db: serviceProvider.database)
        return WWDCastAPIImpl(serviceProvider: serviceProvider, sessionsCache: cache)
    }()
    
    func tabbarController() -> UIViewController {
        let sessionsSearchController = self.sessionsSearchController()
        sessionsSearchController.tabBarItem = UITabBarItem(tabBarSystemItem: .Search, tag: 0)
        let favoriteSessionsController = self.favoriteSessionsController()
        favoriteSessionsController.tabBarItem = UITabBarItem(tabBarSystemItem: .Favorites, tag: 1)
        let tabbarController = TabBarController()
        tabbarController.viewControllers = [sessionsSearchController, favoriteSessionsController]
        return tabbarController
    }
    
    func sessionsSearchController() -> UIViewController {
        let viewModel = SessionsSearchViewModelImpl(api: self.api, router: self.router)
        let view = SessionsSearchViewController(viewModel: viewModel)
        let searchNavigationController = UINavigationController(rootViewController: view)
        searchNavigationController.navigationBar.tintColor = UIColor.blackColor()
        
        self.router.navigationController = searchNavigationController
        return searchNavigationController
    }

    func filterController(filter: Filter, completion: FilterModuleCompletion) -> UIViewController {
        let viewModel = FilterViewModelImpl(filter: filter, completion: completion)
        let view = FilterViewController(viewModel: viewModel)
        let navigationController = UINavigationController(rootViewController: view)
        navigationController.navigationBar.tintColor = UIColor.blackColor()
        return navigationController
    }

    func sessionDetailsController(session: Session) -> UIViewController {
        let viewModel = SessionDetailsViewModelImpl(session: session, api: self.api, router: self.router)
        return SessionDetailsViewController(viewModel: viewModel)
    }
    
    func favoriteSessionsController() -> UIViewController {
        let router = WWDCastRouterImpl(moduleFactory: self)
        let viewModel = FavoriteSessionsViewModelImpl(api: self.api, router: router)
        let view = FavoriteSessionsViewController(viewModel: viewModel)
        let searchNavigationController = UINavigationController(rootViewController: view)
        searchNavigationController.navigationBar.tintColor = UIColor.blackColor()
        
        router.navigationController = searchNavigationController
        return searchNavigationController
    }

}
