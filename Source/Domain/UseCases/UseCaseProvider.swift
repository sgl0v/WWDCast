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
    private let sessionsDataSource: AnyDataSource<Session>

    init(googleCastService: GoogleCastServiceType, sessionsDataSource: AnyDataSource<Session>) {
        self.googleCastService = googleCastService
        self.sessionsDataSource = sessionsDataSource
    }

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
