//
//  MockUseCase.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 01/03/2017.
//  Copyright © 2017 Maksym Shcheglov. All rights reserved.
//

import Foundation
import RxSwift
@testable import WWDCast

class MockSessionsSearchUseCase: SessionsSearchUseCaseType {

    typealias SessionsObservable = Observable<[Session]>
    typealias SearchObservable = (String) -> Observable<[Session]>

    var sessionsObservable: SessionsObservable?
    var searchObservable: SearchObservable?

    var sessions: Observable<[Session]> {
        guard let observable = self.sessionsObservable else {
            fatalError("Not implemented")
        }
        return observable
    }

    func search(with query: String) -> Observable<[Session]> {
        guard let observable = self.searchObservable else {
            fatalError("Not implemented")
        }
        return observable(query)

    }
}
