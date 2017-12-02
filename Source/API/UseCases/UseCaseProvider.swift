//
//  UseCaseProvider.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 02/12/2017.
//  Copyright © 2017 Maksym Shcheglov. All rights reserved.
//

import Foundation

class UseCaseProvider {

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
        let googleCast = GoogleCastService(applicationID: WWDCastEnvironment.googleCastAppID)
        return SessionsDetailsUseCase(googleCast: googleCast, dataSource: self.sessionsDataSource)
    }()

    lazy var favoriteSessionsUseCase: FavoriteSessionsUseCaseType = {
        return FavoriteSessionsUseCase(dataSource: self.sessionsDataSource)
    }()

}
