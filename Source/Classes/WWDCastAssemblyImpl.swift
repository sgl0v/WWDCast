//
//  SessionsSearchWireframeImpl.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 04/07/16.
//  Copyright © 2016 Maksym Shcheglov. All rights reserved.
//

import UIKit
import GoogleCast

class WWDCastAssemblyImpl: WWDCastAssembly {
    
    lazy var router: WWDCastRouterImpl = {
        return WWDCastRouterImpl(moduleFactory: self)
    }()
    
    func sessionsSearchController() -> UIViewController {
        let serviceProvider = ServiceProviderImpl.defaultServiceProvider
        let presenter = SessionsSearchPresenterImpl(router: router)
        let view = SessionsSearchViewController(viewModel: presenter)
        let interactor = SessionsSearchInteractorImpl(presenter: presenter, serviceProvider: serviceProvider)
        presenter.interactor = interactor
        let navigationController = UINavigationController(rootViewController: view)
        navigationController.navigationBar.tintColor = UIColor.blackColor()
        self.router.navigationController = navigationController

        let castContext = GCKCastContext.sharedInstance()
        let castContainerVC = castContext.createCastContainerControllerForViewController(navigationController)
        castContext.useDefaultExpandedMediaControls = true
        castContainerVC.miniMediaControlsItemEnabled = true

        return castContainerVC
    }
    
    func filterController(filter: Filter, completion: FilterModuleCompletion) -> UIViewController {
        let viewModel = FilterViewModelImpl(filter: filter, completion: completion)
        let view = FilterViewController(viewModel: viewModel)
        let navigationController = UINavigationController(rootViewController: view)
        navigationController.navigationBar.tintColor = UIColor.blackColor()
        return navigationController
    }

    func sessionDetailsController(session: Session) -> UIViewController {
        let serviceProvider = ServiceProviderImpl.defaultServiceProvider
        let viewModel = SessionDetailsViewModelImpl(session: session, serviceProvider: serviceProvider, router: self.router)
        return SessionDetailsViewController(viewModel: viewModel)
    }

}
