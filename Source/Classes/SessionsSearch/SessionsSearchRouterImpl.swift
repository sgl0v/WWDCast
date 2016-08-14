//
//  SessionsSearchRouterImpl.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 06/07/16.
//  Copyright © 2016 Maksym Shcheglov. All rights reserved.
//

import UIKit

class SessionsSearchRouterImpl: SessionsSearchRouter {
    weak var moduleFactory: WWDCastAssembly!
    weak var navigationController: UINavigationController!

    init(moduleFactory: WWDCastAssembly) {
        self.moduleFactory = moduleFactory
    }

    func showSessionDetails(withId Id: String) {
        let module = self.moduleFactory.sessionDetailsModule(withId: Id)
        self.navigationController.pushViewController(module, animated: true)
    }
}