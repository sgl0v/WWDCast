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
        let view = SessionsSearchViewController()
        let presenter = SessionsSearchPresenterImpl(view: view, router: router)
        let interactor = SessionsSearchInteractorImpl(presenter: presenter, serviceProvider: serviceProvider)
        view.presenter = presenter
        presenter.interactor = interactor
        let navigationController = UINavigationController(rootViewController: view)
        self.router.navigationController = navigationController

        let castContext = GCKCastContext.sharedInstance()
        let castContainerVC = castContext.createCastContainerControllerForViewController(navigationController)
        castContext.useDefaultExpandedMediaControls = true
        castContainerVC.miniMediaControlsItemEnabled = true

        return castContainerVC
    }
    
    func filterController() -> UIViewController {
        let view = FilterViewController()
        return UINavigationController(rootViewController: view)
    }

    func sessionDetailsController(withId Id: String) -> UIViewController {
        let serviceProvider = ServiceProviderImpl.defaultServiceProvider
        let view = SessionDetailsViewController()
        let presenter = SessionDetailsPresenterImpl(view: view, router: self.router)
        let interactor = SessionDetailsInteractorImpl(presenter: presenter, serviceProvider: serviceProvider, sessionId: Id)
        view.presenter = presenter
        presenter.interactor = interactor
        return view
    }

}
