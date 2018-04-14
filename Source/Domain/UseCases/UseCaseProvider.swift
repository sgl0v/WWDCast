//
//  UseCaseProvider.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 02/12/2017.
//  Copyright © 2017 Maksym Shcheglov. All rights reserved.
//

import Foundation

final class UseCaseProvider {

    private let googleCastService: GoogleCastServiceType
    private let reachabilityService: ReachabilityServiceType
    private let networkService: NetworkServiceType
    private let sessionsDataSource: AnyDataSource<Session>
    private let filterRepository: Repository<Filter>

    init(googleCastService: GoogleCastServiceType, networkService: NetworkServiceType, reachabilityService: ReachabilityServiceType, sessionsDataSource: AnyDataSource<Session>, filterRepository: Repository<Filter>) {
        self.googleCastService = googleCastService
        self.networkService = networkService
        self.reachabilityService = reachabilityService
        self.sessionsDataSource = sessionsDataSource
        self.filterRepository = filterRepository
    }

    var sessionsSearchUseCase: SessionsSearchUseCaseType {
        return SessionsSearchUseCase(dataSource: self.sessionsDataSource, filterRepository: self.filterRepository)
    }

    lazy var favoriteSessionsUseCase: FavoriteSessionsUseCaseType = {
        return FavoriteSessionsUseCase(dataSource: self.sessionsDataSource)
    }()

    var filterUseCase: FilterUseCaseType {
        return FilterUseCase(filterRepository: self.filterRepository)
    }

    func sessionDetailsUseCase(sessionId: String) -> SessionDetailsUseCaseType {
        return SessionDetailsUseCase(sessionId: sessionId, googleCast: self.googleCastService, dataSource: self.sessionsDataSource)
    }

    lazy var imageLoadUseCase: ImageLoadUseCaseType = {
        return ImageLoadUseCase(network: self.networkService, reachability: self.reachabilityService)
    }()

}
