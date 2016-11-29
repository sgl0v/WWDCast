//
//  SessionsSearchWireframeImpl.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 04/07/16.
//  Copyright © 2016 Maksym Shcheglov. All rights reserved.
//

import UIKit

class WWDCastAssemblyImpl: WWDCastAssembly {
    
    lazy var sessionsRouter: WWDCastRouterImpl = {
        return WWDCastRouterImpl(moduleFactory: self)
    }()

    lazy var favoriteSessionsRouter: WWDCastRouterImpl = {
        return WWDCastRouterImpl(moduleFactory: self)
    }()

    lazy var api: WWDCastAPI = {
        let serviceProvider = ServiceProviderImpl.defaultServiceProvider
        return WWDCastAPIImpl(serviceProvider: serviceProvider)
    }()
    
    func tabBarController() -> UIViewController {
        let sessionsSearchController = self.sessionsSearchController()
        sessionsSearchController.tabBarItem = UITabBarItem(tabBarSystemItem: .search, tag: 0)
        let favoriteSessionsController = self.favoriteSessionsController()
        favoriteSessionsController.tabBarItem = UITabBarItem(tabBarSystemItem: .favorites, tag: 1)
        let tabbarController = TabBarController()
        tabbarController.tabBar.tintColor = UIColor.black
        tabbarController.viewControllers = [sessionsSearchController, favoriteSessionsController]
        return tabbarController
    }
    
    func sessionsSearchController() -> UIViewController {
        let viewModel = SessionsSearchViewModelImpl(api: self.api, router: self.sessionsRouter)
        let view = SessionsSearchViewController(viewModel: viewModel)
        let navigationController = UINavigationController(rootViewController: view)
        navigationController.navigationBar.tintColor = UIColor.black
        
        self.sessionsRouter.navigationController = navigationController
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
        let viewModel = SessionDetailsViewModelImpl(sessionId: sessionId, api: self.api, router: self.sessionsRouter)
        return SessionDetailsViewController(viewModel: viewModel)
    }
    
    func favoriteSessionsController() -> UIViewController {
        let viewModel = FavoriteSessionsViewModelImpl(api: self.api, router: self.favoriteSessionsRouter)
        let view = FavoriteSessionsViewController(viewModel: viewModel)
        let navigationController = UINavigationController(rootViewController: view)
        navigationController.navigationBar.tintColor = UIColor.black
        
        self.favoriteSessionsRouter.navigationController = navigationController
        return navigationController
    }
    
    func favoriteSessionDetailsController(_ sessionId: String) -> UIViewController {
        let viewModel = SessionDetailsViewModelImpl(sessionId: sessionId, api: self.api, router: self.favoriteSessionsRouter)
        return SessionDetailsViewController(viewModel: viewModel)
    }

}
