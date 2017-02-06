//
//  SessionsSearchViewModelImpl.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 04/07/16.
//  Copyright © 2016 Maksym Shcheglov. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class SessionsSearchViewModelImpl: SessionsSearchViewModel {
    private let api: WWDCastAPI
    private weak var delegate: SessionsSearchDelegate?
    private let filter = Variable(Filter())
    private let disposeBag = DisposeBag()
    private let activityIndicator = ActivityIndicator()

    init(api: WWDCastAPI, delegate: SessionsSearchDelegate) {
        self.api = api
        self.delegate = delegate
    }

    // MARK: SessionsSearchViewModel

    lazy var sessionSections: Driver<[SessionSectionViewModel]> = {
        let sessionsObservable = self.api.sessions //.trackActivity(self.activityIndicator)
        return Observable.combineLatest(sessionsObservable, self.filter.asObservable(), resultSelector: self.applyFilter)
            .map(SessionSectionViewModelBuilder.build)
            .asDriver(onErrorJustReturn: [])
    }()

    var isLoading: Driver<Bool> {
        return self.activityIndicator.asDriver()
    }

    let title = Driver.just(NSLocalizedString("WWDCast", comment: "Session search view title"))

    func didSelect(item: SessionItemViewModel) {
        self.delegate?.sessionsSearchWantsToShowSessionDetails(withId: item.uniqueID)
    }

    func didTapFilter() {
        self.delegate?.sessionsSearchWantsToShowFilter(self.filter.value) {[unowned self] filter in
            self.filter.value = filter
        }
    }

    func didStartSearch(withQuery query: String) {
        var filter = self.filter.value
        filter.query = query
        self.filter.value = filter
    }

    // MARK: Private

    private func applyFilter(sessions: [Session], filter: Filter) -> [Session] {
        return sessions.apply(filter)
    }

}
