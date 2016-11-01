//
//  SessionsSearchRouterImpl.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 06/07/16.
//  Copyright © 2016 Maksym Shcheglov. All rights reserved.
//

import UIKit
import RxSwift

class WWDCastRouterImpl: SessionsSearchRouter, SessionDetailsRouter, FavoriteSessionsRouter {
    weak var moduleFactory: WWDCastAssembly!
    weak var navigationController: UINavigationController!

    init(moduleFactory: WWDCastAssembly) {
        self.moduleFactory = moduleFactory
    }

    // MARK: SessionsSearchRouter
    
    func showSessionDetails(_ sessionId: String) {
        let controller = self.moduleFactory.sessionDetailsController(sessionId)
        self.navigationController.pushViewController(controller, animated: true)
    }
    
    func showFilterController(withFilter filter: Filter, completion: @escaping (Filter) -> Void) {
        let controller = self.moduleFactory.filterController(filter) {[unowned self] result in
            self.navigationController.dismiss(animated: true, completion: { 
                guard case .finished(let filter) = result else {
                    return
                }
                completion(filter)
            })
        }
        self.navigationController.present(controller, animated: true, completion: nil)
    }
    
    // MARK: SessionDetailsRouter
    
    func showAlert(_ title: String?, message: String) {
        let alertView = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertView.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "OK button title"), style: .cancel) { _ in
            })
        self.navigationController.present(alertView, animated: true, completion: nil)
    }
    
    func promptFor<Action : CustomStringConvertible>(_ title: String?, message: String?, cancelAction: Action, actions: [Action]) -> Observable<Action> {
        let alertView = UIAlertController.promptFor(title, message: message, cancelAction: cancelAction, actions: actions)
        return alertView(self.navigationController)
    }
    
}
