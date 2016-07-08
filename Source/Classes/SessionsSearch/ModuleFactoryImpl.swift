//
//  SessionsSearchWireframeImpl.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 04/07/16.
//  Copyright © 2016 Maksym Shcheglov. All rights reserved.
//

import UIKit

protocol ModuleFactory {
    static func sessionsSearchModule() -> UIViewController
    static func sessionDetailsModule() -> UIViewController
}

class ModuleFactoryImpl: ModuleFactory {

    static func sessionsSearchModule() -> UIViewController {
        let view = SessionsSearchViewController()
        let presenter = SessionsSearchPresenterImpl(view: view)
        let interactor = SessionsSearchInteractorImpl(presenter: presenter)
        view.presenter = presenter
        presenter.interactor = interactor
        return UINavigationController(rootViewController: view)
    }

    static func sessionDetailsModule() -> UIViewController {

    }

}