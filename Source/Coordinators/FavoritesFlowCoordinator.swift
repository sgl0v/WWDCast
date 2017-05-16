//
//  FavoritesFlowCoordinator.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 18/02/2017.
//  Copyright © 2017 Maksym Shcheglov. All rights reserved.
//

import UIKit

/// The `FavoritesFlowCoordinator` takes control over the flows on the favorites screen
class FavoritesFlowCoordinator: FlowCoordinator {
    fileprivate let rootController: UINavigationController
    fileprivate let dependencyProvider: FavoritesFlowCoordinatorDependencyProvider

    init(rootController: UINavigationController, dependencyProvider: FavoritesFlowCoordinatorDependencyProvider) {
        self.rootController = rootController
        self.dependencyProvider = dependencyProvider
    }

    func start() {
        let searchController = self.dependencyProvider.favoriteSessionsController(delegate: self, previewProvider: self)
        self.rootController.setViewControllers([searchController], animated: false)
    }

}

extension FavoritesFlowCoordinator: TableViewControllerPreviewProvider {

    func previewController<Item>(forItem item: Item) -> UIViewController? {
        guard let item = item as? SessionItemViewModel else {
            return nil
        }
        return self.dependencyProvider.sessionDetailsController(item.uniqueID)
    }

}

extension FavoritesFlowCoordinator: FavoriteSessionsViewModelDelegate {

    func favoriteSessionsViewModel(_ viewModel: FavoriteSessionsViewModelProtocol, wantsToShowSessionDetailsWith sessionId: String) {
        let controller = self.dependencyProvider.sessionDetailsController(sessionId)
        self.rootController.pushViewController(controller, animated: true)
    }

}
