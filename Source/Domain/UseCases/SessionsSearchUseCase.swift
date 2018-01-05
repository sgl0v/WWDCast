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

    /// Runs session search with a query string
    func search(with query: String) -> Observable<[Session]>
}

class SessionsSearchUseCase: SessionsSearchUseCaseType {

    private let dataSource: AnyDataSource<Session>
    fileprivate let _filter = Variable(Filter())

    var filter: Observable<Filter> {
        return _filter.asObservable().distinctUntilChanged()
    }

    lazy var sessions: Observable<[Session]> = {
        let sessions = self.dataSource.allObjects()
        return Observable.combineLatest(sessions, self.filter, resultSelector: self.applyFilter)
    }()

    init(dataSource: AnyDataSource<Session>) {
        self.dataSource = dataSource
    }

    func search(with query: String) -> Observable<[Session]> {
        let filter = self._filter.value
        self._filter.value = Filter(query: query, years: filter.years, platforms: filter.platforms, tracks: filter.tracks)
        Log.debug("\(self._filter.value)")
        return self.sessions
    }

    private func applyFilter(sessions: [Session], filter: Filter) -> [Session] {
        return sessions.apply(filter)
    }

}

extension SessionsSearchUseCase: FilterUseCaseType {

    func filter(with years: [Session.Year]) {
        let filter = self._filter.value
        self._filter.value = Filter(query: filter.query, years: years, platforms: filter.platforms, tracks: filter.tracks)
        Log.debug("\(self._filter.value)")
    }

    func filter(with platforms: Session.Platform) {
        let filter = self._filter.value
        self._filter.value = Filter(query: filter.query, years: filter.years, platforms: platforms, tracks: filter.tracks)
        Log.debug("\(self._filter.value)")
    }

    func filter(with tracks: [Session.Track]) {
        let filter = self._filter.value
        self._filter.value = Filter(query: filter.query, years: filter.years, platforms: filter.platforms, tracks: tracks)
        Log.debug("\(self._filter.value)")
    }
}
