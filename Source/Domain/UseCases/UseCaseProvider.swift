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

    var sessionsSearchUseCase: SessionsSearchUseCaseType {
        return self.searchAndFilterUseCase
    }

    lazy var favoriteSessionsUseCase: FavoriteSessionsUseCaseType = {
        return FavoriteSessionsUseCase(dataSource: self.sessionsDataSource)
    }()

    var filterUseCase: FilterUseCaseType {
        return self.searchAndFilterUseCase
    }

    func sessionDetailsUseCase(sessionId: String) -> SessionsDetailsUseCaseType {
        return SessionsDetailsUseCase(sessionId: sessionId, googleCast: self.googleCastService, dataSource: self.sessionsDataSource)
    }

    // MARK: Private

    lazy var searchAndFilterUseCase = SessionsSearchUseCase(dataSource: self.sessionsDataSource)
}
