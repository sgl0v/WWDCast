//
//  SessionsSearchWireframeImpl.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 04/07/16.
//  Copyright © 2016 Maksym Shcheglov. All rights reserved.
//

import UIKit

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
        return navigationController
    }

    func sessionDetailsModule(withId Id: String) -> UIViewController {
        let view = SessionDetailsViewController()
        let presenter = SessionDetailsPresenterImpl(view: view)
        let interactor = SessionDetailsInteractorImpl(presenter: presenter, sessionId: Id)
        view.presenter = presenter
        presenter.interactor = interactor
        return view
    }

}
