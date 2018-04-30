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
    private let sessionsRepository: AnyRepository<[Session]>
    private let filterRepository: AnyRepository<Filter>

    init(googleCastService: GoogleCastServiceType, networkService: NetworkServiceType, reachabilityService: ReachabilityServiceType, sessionsRepository: AnyRepository<[Session]>, filterRepository: AnyRepository<Filter>) {
        self.googleCastService = googleCastService
        self.networkService = networkService
        self.reachabilityService = reachabilityService
        self.sessionsRepository = sessionsRepository
        self.filterRepository = filterRepository
    }

    var sessionsSearchUseCase: SessionsSearchUseCaseType {
        return SessionsSearchUseCase(sessionsRepository: self.sessionsRepository, filterRepository: self.filterRepository)
    }

    lazy var favoriteSessionsUseCase: FavoriteSessionsUseCaseType = {
        return FavoriteSessionsUseCase(sessionsRepository: self.sessionsRepository)
    }()

    var filterUseCase: FilterUseCaseType {
        return FilterUseCase(repository: self.filterRepository)
    }

    func sessionDetailsUseCase(sessionId: String) -> SessionDetailsUseCaseType {
        return SessionDetailsUseCase(sessionId: sessionId, googleCast: self.googleCastService, sessionsRepository: self.sessionsRepository)
    }

    lazy var imageLoadUseCase: ImageLoadUseCaseType = {
        return ImageLoadUseCase(network: self.networkService, reachability: self.reachabilityService)
    }()

}
