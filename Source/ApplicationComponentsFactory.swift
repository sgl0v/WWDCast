//
//  SessionsSearchWireframeImpl.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 04/07/16.
//  Copyright © 2016 Maksym Shcheglov. All rights reserved.
//

import UIKit

/// The ApplicationComponentsFactory takes responsibity of creating application components and establishing dependencies between them.
final class ApplicationComponentsFactory {

    private let servicesProvider: ServicesProvider

    init(servicesProvider: ServicesProvider = ServicesProvider.defaultProvider()) {
        self.servicesProvider = servicesProvider
    }

    fileprivate lazy var sessionsRepository: AnyRepository<[Session]> = {
        let coreDataController = CoreDataController(name: "WWDCast")
        let localRepository: AnyRepository<[Session]> = AnyRepository(repository: LocalRepository<SessionManagedObject>(coreDataController: coreDataController))
        let remoteRepository: AnyRepository<[Session]> = AnyRepository(repository: RemoteRepository(network: self.servicesProvider.network, reachability: self.servicesProvider.reachability))
        return AnyRepository(repository: CompositeRepository(remoteRepository: remoteRepository, localRepository: localRepository))
    }()

    fileprivate lazy var filterRepository: AnyRepository<Filter> = {
        let filterRepository = InMemoryRepository<Filter>(value: Filter())
        return AnyRepository(repository: filterRepository)
    }()

    fileprivate lazy var useCaseProvider: UseCaseProvider = {
        return UseCaseProvider(googleCastService: self.servicesProvider.googleCast, networkService: self.servicesProvider.network, reachabilityService: self.servicesProvider.reachability, sessionsRepository: self.sessionsRepository, filterRepository: self.filterRepository)
    }()

}

extension ApplicationComponentsFactory: ApplicationFlowCoordinatorDependencyProvider {

    func tabBarController() -> UITabBarController {
        return TabBarController()
    }

}

extension ApplicationComponentsFactory: SearchFlowCoordinatorDependencyProvider {

    func sessionsSearchController(navigator: SessionsSearchNavigator, previewProvider: TableViewControllerPreviewProvider) -> UIViewController {
        let useCase = self.useCaseProvider.sessionsSearchUseCase
        let imageLoadUseCase = self.useCaseProvider.imageLoadUseCase
        let viewModel = SessionsSearchViewModel(useCase: useCase, imageLoadUseCase: imageLoadUseCase, navigator: navigator)
        let view = SessionsSearchViewController(viewModel: viewModel)
        view.previewProvider = previewProvider
        return view
    }

    func sessionDetailsController(_ sessionId: String) -> UIViewController {
        let useCase = self.useCaseProvider.sessionDetailsUseCase(sessionId: sessionId)
        let imageLoadUseCase = self.useCaseProvider.imageLoadUseCase
        let viewModel = SessionDetailsViewModel(useCase: useCase, imageLoadUseCase: imageLoadUseCase)
        return SessionDetailsViewController(viewModel: viewModel)
    }

    func filterController(navigator: FilterNavigator) -> UIViewController {
        let viewModel = FilterViewModel(useCase: self.useCaseProvider.filterUseCase, navigator: navigator)
        let view = FilterViewController(viewModel: viewModel)
        let navigationController = UINavigationController(rootViewController: view)
        navigationController.navigationBar.tintColor = UIColor.black
        return navigationController
    }

}

extension ApplicationComponentsFactory: FavoritesFlowCoordinatorDependencyProvider {

    func favoriteSessionsController(navigator: FavoriteSessionsNavigator, previewProvider: TableViewControllerPreviewProvider) -> UIViewController {
        let useCase = self.useCaseProvider.favoriteSessionsUseCase
        let imageLoadUseCase = self.useCaseProvider.imageLoadUseCase
        let viewModel = FavoriteSessionsViewModel(useCase: useCase, imageLoadUseCase: imageLoadUseCase, navigator: navigator)
        let view =  FavoriteSessionsViewController(viewModel: viewModel)
        view.previewProvider = previewProvider
        return view
    }

}
