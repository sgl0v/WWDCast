//
//  SessionsSearchUserCase.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 09/11/2017.
//  Copyright © 2017 Maksym Shcheglov. All rights reserved.
//

import Foundation
import RxSwift

protocol SessionsSearchUseCaseType {

    /// The sequence of WWDC Sessions
    var sessions: Observable<[Session]> { get }

    /// The session search filter
    var filter: Observable<Filter> { get }

    /// Runs session search with a query string
    func search(with query: String) -> Observable<[Session]>
}

class SessionsSearchUseCase: SessionsSearchUseCaseType {

    private let dataSource: AnyDataSource<Session>
    private let _filter = Variable(Filter())

    var filter: Observable<Filter> {
        return _filter.asObservable()
    }

    lazy var sessions: Observable<[Session]> = {
        let sessions = self.dataSource.allObjects()
        return Observable.combineLatest(sessions, self.filter.asObservable(), resultSelector: self.applyFilter)
    }()

    init(dataSource: AnyDataSource<Session>) {
        self.dataSource = dataSource
    }

    func search(with query: String) -> Observable<[Session]> {
        var filter = self._filter.value
        filter.query = query
        self._filter.value = filter
        return sessions
    }

    private func applyFilter(sessions: [Session], filter: Filter) -> [Session] {
        return sessions.apply(filter)
    }

}
