//
//  SessionsSearchRouterImpl.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 06/07/16.
//  Copyright © 2016 Maksym Shcheglov. All rights reserved.
//

import UIKit
import RxSwift

class WWDCastRouterImpl: SessionsSearchRouter, SessionDetailsRouter {
    weak var moduleFactory: WWDCastAssembly!
    weak var navigationController: UINavigationController!

    init(moduleFactory: WWDCastAssembly) {
        self.moduleFactory = moduleFactory
    }

    func showSessionDetails(withId Id: String) {
        let module = self.moduleFactory.sessionDetailsModule(withId: Id)
        self.navigationController.pushViewController(module, animated: true)
    }
    
    func showAlert<Action : CustomStringConvertible>(title: String?, message: String?, style: UIAlertControllerStyle, cancelAction: Action, actions: [Action]) -> Observable<Action> {
        let alertView = UIAlertController.promptFor(title, message: message, style: style, cancelAction: cancelAction, actions: actions)
        return alertView(self.navigationController)
    }
    
}
