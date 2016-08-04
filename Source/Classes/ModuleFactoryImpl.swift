//
//  SessionsSearchWireframeImpl.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 04/07/16.
//  Copyright © 2016 Maksym Shcheglov. All rights reserved.
//

import UIKit
import GoogleCast

class ModuleFactoryImpl: ModuleFactory {

    func sessionsSearchModule() -> UIViewController {
        let serviceProvider = ServiceProviderImpl.defaultServiceProvider()
        let view = SessionsSearchViewController()
        let router = SessionsSearchRouterImpl(moduleFactory: self)
        let presenter = SessionsSearchPresenterImpl(view: view, router: router)
        let interactor = SessionsSearchInteractorImpl(presenter: presenter, serviceProvider: serviceProvider)
        view.presenter = presenter
        presenter.interactor = interactor
        let navigationController = UINavigationController(rootViewController: view)
        router.navigationController = navigationController
        
        let options = GCKCastOptions(receiverApplicationID: WWDCEnvironment.googleCastAppID)
        GCKCastContext.setSharedInstanceWithOptions(options)
        
        let castContext = GCKCastContext.sharedInstance()
        
        let castContainerVC = castContext.createCastContainerControllerForViewController(navigationController)
        castContainerVC.miniMediaControlsItemEnabled = true

        return castContainerVC
    }

    func sessionDetailsModule(withId Id: String) -> UIViewController {
        let serviceProvider = ServiceProviderImpl.defaultServiceProvider()
        let view = SessionDetailsViewController()
        let presenter = SessionDetailsPresenterImpl(view: view)
        let interactor = SessionDetailsInteractorImpl(presenter: presenter, serviceProvider: serviceProvider, sessionId: Id)
        view.presenter = presenter
        presenter.interactor = interactor
        return view
    }

}
