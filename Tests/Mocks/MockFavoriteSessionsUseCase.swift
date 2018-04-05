//
//  MockFavoriteSessionsUseCase.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 05/04/2018.
//  Copyright © 2018 Maksym Shcheglov. All rights reserved.
//

import Foundation
import RxSwift
@testable import WWDCast

class MockFavoriteSessionsUseCase: FavoriteSessionsUseCaseType {

    typealias SessionsObservable = Observable<[Session]>

    var sessionsObservable: SessionsObservable?

    var favoriteSessions: Observable<[Session]> {
        guard let observable = self.sessionsObservable else {
            fatalError("Not implemented")
        }
        return observable
    }

}
