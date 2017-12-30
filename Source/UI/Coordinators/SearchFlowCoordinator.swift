//
//  SearchFlowCoordinator.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 18/02/2017.
//  Copyright © 2017 Maksym Shcheglov. All rights reserved.
//

import UIKit

/// The `SearchFlowCoordinator` takes control over the flows on the search screen
class SearchFlowCoordinator: FlowCoordinator {
    fileprivate let rootController: UINavigationController
    fileprivate let dependencyProvider: SearchFlowCoordinatorDependencyProvider

    init(rootController: UINavigationController, dependencyProvider: SearchFlowCoordinatorDependencyProvider) {
        self.rootController = rootController
        self.dependencyProvider = dependencyProvider
    }

    func start() {
        let searchController = self.dependencyProvider.sessionsSearchController(navigator: self, previewProvider: self)
        self.rootController.setViewControllers([searchController], animated: false)
    }

}

extension SearchFlowCoordinator: TableViewControllerPreviewProvider {

    func previewController<Item>(forItem item: Item) -> UIViewController? {
        guard let item = item as? SessionItemViewModel else {
            return nil
        }
        return self.dependencyProvider.sessionDetailsController(item.id)
    }

}

extension SearchFlowCoordinator: SessionsSearchNavigator {

    func showFilter() {
        let controller = self.dependencyProvider.filterController()
        self.rootController.present(controller, animated: true, completion: nil)
    }

    func showDetails(forSession sessionId: String) {
        let controller = self.dependencyProvider.sessionDetailsController(sessionId)
        self.rootController.pushViewController(controller, animated: true)
    }

}
