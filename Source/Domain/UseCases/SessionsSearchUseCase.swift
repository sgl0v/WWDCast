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
    private let filterRepository: Repository<Filter>

    lazy var sessions: Observable<[Session]> = {
        let sessions = self.dataSource.allObjects()
        return Observable.combineLatest(sessions, self.filterRepository.asObservable(),
                                        resultSelector: self.applyFilter).share(replay: 1)
    }()

    init(dataSource: AnyDataSource<Session>, filterRepository: Repository<Filter>) {
        self.dataSource = dataSource
        self.filterRepository = filterRepository
    }

    func search(with query: String) -> Observable<[Session]> {
        let filter = self.filterRepository.value
        self.filterRepository.value = Filter(query: query, years: filter.years, platforms: filter.platforms, tracks: filter.tracks)
        return self.sessions
    }

    private func applyFilter(sessions: [Session], filter: Filter) -> [Session] {
        return sessions.apply(filter)
    }

}
