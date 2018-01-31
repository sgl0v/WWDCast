//
//  SessionsSearchUserCase.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 09/11/2017.
//  Copyright © 2017 Maksym Shcheglov. All rights reserved.
//

import Foundation
import RxSwift

class Repository<Element> {

    private let _value: Variable<Element>

    /// Gets or sets current value of variable.
    ///
    /// Whenever a new value is set, all the observers are notified of the change.
    ///
    /// Even if the newly set value is same as the old value, observers are still notified for change.
    public var value: Element {
        get {
            return self._value.value
        }
        set(newValue) {
            self._value.value = newValue
        }
    }

    /// Initializes variable with initial value.
    ///
    /// - parameter value: Initial variable value.
    init(value: Element) {
        self._value = Variable(value)
    }

    public func asObservable() -> Observable<Element> {
        return self._value.asObservable()
    }

}

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
                                        resultSelector: self.applyFilter).shareReplayLatestWhileConnected()
    }()

    init(dataSource: AnyDataSource<Session>, filterRepository: Repository<Filter>) {
        self.dataSource = dataSource
        self.filterRepository = filterRepository
    }

    func search(with query: String) -> Observable<[Session]> {
        return Observable.just(self.filterRepository.value).map({ filter in
            return Filter(query: query, years: filter.years, platforms: filter.platforms, tracks: filter.tracks)
        }).flatMap(self.sessions)
    }

    private func applyFilter(sessions: [Session], filter: Filter) -> [Session] {
        return sessions.apply(filter)
    }

}

class FilterUseCase: FilterUseCaseType {

    private let filterRepository: Repository<Filter>
    private let _value: Variable<Filter>

    public var value: Filter {
        get {
            return self._value.value
        }
        set(newValue) {
            self._value.value = newValue
        }
    }

    public var filterObservable: Observable<Filter> {
        return self._value.asObservable()
    }

//            let oldValue = self.value
//            self.value = Filter(query: oldValue.query, years: oldValue.years, platforms: oldValue.platforms, tracks: oldValue.tracks)

    init(filterRepository: Repository<Filter>) {
        self.filterRepository = filterRepository
        self._value = Variable(self.filterRepository.value)
    }

    func save() {
        self.filterRepository.value = self.value
    }

}
