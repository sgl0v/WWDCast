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

    private let sessionsRepository: AnyRepository<[Session]>
    private let filterRepository: AnyRepository<Filter>

    lazy var sessions: Observable<[Session]> = {
        let sessions = self.sessionsRepository.asObservable().sort()
        return Observable.combineLatest(sessions, self.filterRepository.asObservable(),
                                        resultSelector: self.applyFilter)
            .subscribeOn(Scheduler.backgroundWorkScheduler)
            .observeOn(Scheduler.mainScheduler)
    }()

    init(sessionsRepository: AnyRepository<[Session]>, filterRepository: AnyRepository<Filter>) {
        self.sessionsRepository = sessionsRepository
        self.filterRepository = filterRepository
    }

    func search(with query: String) -> Observable<[Session]> {
        return self.filterRepository
            .asObservable()
            .map({ filter in
                return Filter(query: query, years: filter.years, platforms: filter.platforms, tracks: filter.tracks)
            })
            .flatMap(self.filterRepository.update)
            .mapToVoid()
            .flatMap(self.sessions)
    }

    private func applyFilter(sessions: [Session], filter: Filter) -> [Session] {
        return sessions.apply(filter)
    }

}
