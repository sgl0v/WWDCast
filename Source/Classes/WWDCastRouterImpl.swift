//
//  SessionsSearchRouterImpl.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 06/07/16.
//  Copyright © 2016 Maksym Shcheglov. All rights reserved.
//

import UIKit
import RxSwift

class WWDCastApplicationFlowCoordinator {
    fileprivate let rootController: UIViewController
    fileprivate var searchNavigationController: UINavigationController!
    fileprivate var favoritesNavigationController: UINavigationController!
    fileprivate let assembly: WWDCastAssembly

    init(rootController: UIViewController, assembly: WWDCastAssembly) {
        self.rootController = rootController
        self.assembly = assembly
    }

    func start() {

        let searchController = self.assembly.sessionsSearchController(delegate: self, previewProvider: self)
        searchController.tabBarItem = UITabBarItem(tabBarSystemItem: .search, tag: 0)
        self.searchNavigationController = UINavigationController(rootViewController: searchController)
        self.searchNavigationController.navigationBar.tintColor = UIColor.black

        let favoritesController = self.assembly.favoriteSessionsController(delegate: self, previewProvider: self)
        favoritesController.tabBarItem = UITabBarItem(tabBarSystemItem: .favorites, tag: 1)
        self.favoritesNavigationController = UINavigationController(rootViewController: favoritesController)
        self.favoritesNavigationController.navigationBar.tintColor = UIColor.black

        let tabBarController = self.assembly.tabBarController()
        tabBarController.viewControllers = [searchNavigationController, favoritesNavigationController]

        self.rootController.addChildViewController(tabBarController)
        self.rootController.view.addSubview(tabBarController.view)
        tabBarController.didMove(toParentViewController: self.rootController)
    }

}

extension WWDCastApplicationFlowCoordinator: TableViewControllerPreviewProvider {

    func previewController<Item>(forItem item: Item) -> UIViewController? {
        guard let item = item as? SessionItemViewModel else {
            return nil
        }
        return self.assembly.sessionDetailsController(item.uniqueID)
    }

}

extension WWDCastApplicationFlowCoordinator: SessionsSearchViewModelDelegate {

    func sessionsSearchViewModel(_ viewModel: SessionsSearchViewModel, wantsToShow filter: Filter, completion: @escaping (Filter) -> Void) {
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

    func sessionsSearchViewModel(_ viewModel: SessionsSearchViewModel, wantsToShowSessionDetailsWith sessionId: String) {
        let controller = self.assembly.sessionDetailsController(sessionId)
        self.searchNavigationController.pushViewController(controller, animated: true)
    }

}

extension WWDCastApplicationFlowCoordinator: FavoriteSessionsViewModelDelegate {

    func favoriteSessionsViewModel(_ viewModel: FavoriteSessionsViewModel, wantsToShowSessionDetailsWith sessionId: String) {
        let controller = self.assembly.sessionDetailsController(sessionId)
        self.favoritesNavigationController.pushViewController(controller, animated: true)
    }

}
