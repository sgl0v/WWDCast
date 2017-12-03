//
//  UseCaseProvider.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 02/12/2017.
//  Copyright © 2017 Maksym Shcheglov. All rights reserved.
//

import Foundation

final class UseCaseProvider {

    fileprivate lazy var googleCastService: GoogleCastService = {
        return GoogleCastService(applicationID: WWDCastEnvironment.googleCastAppID)
    }()

    fileprivate lazy var sessionsDataSource: AnyDataSource<Session> = {

        guard let reachability = ReachabilityService() else {
            fatalError("Failed to create reachability service!")
        }
        let network = NetworkService()

        let coreDataController = CoreDataController(name: "WWDCast")
        let cacheDataSource: AnyDataSource<Session> = AnyDataSource(dataSource: CoreDataSource<SessionManagedObject>(coreDataController: coreDataController))
        let networkDataSource: AnyDataSource<Session> = AnyDataSource(dataSource: NetworkDataSource(network: network, reachability: reachability))
        return AnyDataSource(dataSource: CompositeDataSource(networkDataSource: networkDataSource, coreDataSource: cacheDataSource))
    }()

    lazy var sessionsSearchUseCase: SessionsSearchUseCaseType = {
        return SessionsSearchUseCase(dataSource: self.sessionsDataSource)
    }()

    lazy var sessionDetailsUseCase: SessionsDetailsUseCaseType = {
        return SessionsDetailsUseCase(googleCast: self.googleCastService, dataSource: self.sessionsDataSource)
    }()

    lazy var favoriteSessionsUseCase: FavoriteSessionsUseCaseType = {
        return FavoriteSessionsUseCase(dataSource: self.sessionsDataSource)
    }()

}
