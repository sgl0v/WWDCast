//
//  SessionsSearchWireframeImpl.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 04/07/16.
//  Copyright © 2016 Maksym Shcheglov. All rights reserved.
//

import UIKit
import GoogleCast

class TabBarController: UITabBarController, GCKUIMiniMediaControlsViewControllerDelegate {
    
    private var miniMediaControlsViewController: GCKUIMiniMediaControlsViewController!
    private static let kMiniMediaControlsViewHeight: CGFloat = 60.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let castContext = GCKCastContext.sharedInstance()
        castContext.useDefaultExpandedMediaControls = true
        
        miniMediaControlsViewController = castContext.createMiniMediaControlsViewController()
        miniMediaControlsViewController.delegate = self
        self.addChildViewController(miniMediaControlsViewController)
        self.view.addSubview(miniMediaControlsViewController.view)
        miniMediaControlsViewController.didMoveToParentViewController(self)
        miniMediaControlsViewController.view.hidden = !miniMediaControlsViewController.active
    }
    
    func miniMediaControlsViewController(miniMediaControlsViewController: GCKUIMiniMediaControlsViewController, shouldAppear: Bool) {
        miniMediaControlsViewController.view.hidden = !miniMediaControlsViewController.active
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let y = CGRectGetMaxY(self.view.bounds) - TabBarController.kMiniMediaControlsViewHeight - CGRectGetHeight(self.tabBar.frame)
        miniMediaControlsViewController.view.frame = CGRectMake(0, y, CGRectGetWidth(self.view.bounds), TabBarController.kMiniMediaControlsViewHeight)
    }
}

@objc class WWDCastAssemblyImpl: NSObject, WWDCastAssembly {
    
    lazy var router: WWDCastRouterImpl = {
        return WWDCastRouterImpl(moduleFactory: self)
    }()
    
    lazy var api: WWDCastAPI = {
        let serviceProvider = ServiceProviderImpl.defaultServiceProvider
        return WWDCastAPIImpl(serviceProvider: serviceProvider)
    }()
    
    func sessionsSearchController() -> UIViewController {
        let viewModel = SessionsSearchViewModelImpl(api: self.api, router: self.router)
        let view = SessionsSearchViewController(viewModel: viewModel)
        let searchNavigationController = UINavigationController(rootViewController: view)
        searchNavigationController.navigationBar.tintColor = UIColor.blackColor()
        searchNavigationController.tabBarItem = UITabBarItem(tabBarSystemItem: .Search, tag: 0)
        self.router.navigationController = searchNavigationController

        let favoritesNavigationController = UINavigationController()
        favoritesNavigationController.navigationBar.tintColor = UIColor.blackColor()
        favoritesNavigationController.tabBarItem = UITabBarItem(tabBarSystemItem: .Favorites, tag: 1)
        
        let tabbarController = TabBarController()
        tabbarController.viewControllers = [searchNavigationController, favoritesNavigationController]
        return tabbarController
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

}
