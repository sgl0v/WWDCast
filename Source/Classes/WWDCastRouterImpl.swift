//
//  SessionsSearchRouterImpl.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 06/07/16.
//  Copyright © 2016 Maksym Shcheglov. All rights reserved.
//

import UIKit
import RxSwift

protocol SessionsSearchDelegate: class {
    func sessionsSearchWantsToShowFilter(_ filter: Filter, completion: @escaping (Filter) -> Void)
    func sessionsSearchWantsToShowSessionDetails(withId sessionId: String)
}

protocol FavoriteSessionsDelegate: class {
    func sessionsSearchWantsToShowSessionDetails(withId sessionId: String)
}

class WWDCastApplicationFlowCoordinator {
    fileprivate let rootController: UIViewController
    fileprivate let assembly: WWDCastAssembly

    init(rootController: UIViewController, assembly: WWDCastAssembly) {
        self.rootController = rootController
        self.assembly = assembly
    }

    func start() {
        let tabBarController = self.assembly.tabBarController(delegate: self)
        self.rootController.addChildViewController(tabBarController)
        self.rootController.view.addSubview(tabBarController.view)
        tabBarController.didMove(toParentViewController: self.rootController)
    }
}

extension WWDCastApplicationFlowCoordinator: SessionsSearchDelegate {

    func sessionsSearchWantsToShowFilter(_ filter: Filter, completion: @escaping (Filter) -> Void) {
        let controller = self.assembly.filterController(filter) {[unowned self] result in
            self.rootController.dismiss(animated: true, completion: {
                guard case .finished(let filter) = result else {
                    return
                }
                completion(filter)
            })
        }
        self.rootController.present(controller, animated: true, completion: nil)
    }

    func sessionsSearchWantsToShowSessionDetails(withId sessionId: String) {
//        let controller = self.assembly.favoriteSessionDetailsController(sessionId)
//        self.navigationController.pushViewController(controller, animated: true)
    }
}

extension WWDCastApplicationFlowCoordinator: FavoriteSessionsDelegate {

}

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

    func showFilterController(_ filter: Filter, completion: @escaping (Filter) -> Void) {
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

    func showAlert(withTitle title: String?, message: String) {
        let alertView = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertView.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "OK button title"), style: .cancel) { _ in
            })
        self.navigationController.present(alertView, animated: true, completion: nil)
    }

    func showAlert<Action: CustomStringConvertible>(withTitle title: String?, message: String?, cancelAction: Action, actions: [Action]) -> Observable<UIAlertController.Selection> {
        let alertView = UIAlertController.promptFor(title, message: message, cancelAction: cancelAction, actions: actions)
        return alertView(self.navigationController)
    }

    // MARK: FavoriteSessionsRouter

    func showFavoriteSessionDetails(_ sessionId: String) {
//        let controller = self.moduleFactory.favoriteSessionDetailsController(sessionId)
//        self.navigationController.pushViewController(controller, animated: true)
    }

}
