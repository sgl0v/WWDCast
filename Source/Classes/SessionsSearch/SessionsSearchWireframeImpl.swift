//
//  SessionsSearchWireframeImpl.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 04/07/16.
//  Copyright © 2016 Maksym Shcheglov. All rights reserved.
//

import UIKit

class SessionsSearchWireframeImpl {

    static func createModule() -> UIViewController {
        let view = SessionsSearchViewController()
        let presenter = SessionsSearchPresenterImpl(view: view)
        let interactor = SessionsSearchInteractorImpl(presenter: presenter)
        view.presenter = presenter
        presenter.interactor = interactor
        return view
    }

}