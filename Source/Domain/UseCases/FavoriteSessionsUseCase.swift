//
//  FavoriteSessionsUseCase.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 01/12/2017.
//  Copyright © 2017 Maksym Shcheglov. All rights reserved.
//

import Foundation
import RxSwift

protocol FavoriteSessionsUseCaseType {

    /// The sequence of favorite WWDC Sessions
    var favoriteSessions: Observable<[Session]> { get }
}

class FavoriteSessionsUseCase: FavoriteSessionsUseCaseType {

    private let dataSource: AnyDataSource<Session>

    init(dataSource: AnyDataSource<Session>) {
        self.dataSource = dataSource
    }

    lazy var favoriteSessions: Observable<[Session]> = {
        return self.dataSource
            .allObjects()
            .map({ sessions in return sessions.filter({ $0.favorite }) })
            .subscribeOn(Scheduler.backgroundWorkScheduler)
            .observeOn(Scheduler.mainScheduler)
    }()
}
