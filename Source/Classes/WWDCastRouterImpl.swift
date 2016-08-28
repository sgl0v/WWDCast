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

    // MARK: SessionsSearchRouter
    
    func showSessionDetails(session: Session) {
        let controller = self.moduleFactory.sessionDetailsController(session)
        self.navigationController.pushViewController(controller, animated: true)
    }
    
    func showFilterController(withFilter filter: Filter, completion: (Filter) -> Void) {
        let controller = self.moduleFactory.filterController(filter) {[unowned self] result in
            self.navigationController.dismissViewControllerAnimated(true, completion: { 
                guard case .Finished(let filter) = result else {
                    return
                }
                completion(filter)
            })
        }
        self.navigationController.presentViewController(controller, animated: true, completion: nil)
    }
    
    // MARK: SessionDetailsRouter
    
    func showAlert(title: String, message: String) {
        let alertView = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        alertView.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "OK button title"), style: .Cancel) { _ in
            })
        self.navigationController.presentViewController(alertView, animated: true, completion: nil)
    }
    
    func promptFor<Action : CustomStringConvertible>(title: String?, message: String?, cancelAction: Action, actions: [Action]) -> Observable<Action> {
        let alertView = UIAlertController.promptFor(title, message: message, cancelAction: cancelAction, actions: actions)
        return alertView(self.navigationController)
    }
    
}
