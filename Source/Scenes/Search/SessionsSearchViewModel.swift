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

class SessionsSearchViewModel: SessionsSearchViewModelType {

    private let useCase: SessionsSearchUseCaseType
    private weak var delegate: SessionsSearchViewModelDelegate?
    private let filter = Variable(Filter())
    private let activityIndicator = ActivityIndicator()

    init(useCase: SessionsSearchUseCaseType, delegate: SessionsSearchViewModelDelegate) {
        self.useCase = useCase
        self.delegate = delegate
    }

    // MARK: SessionsSearchViewModelType

    func transform(_ action: SessionsSearchAction) -> Driver<SessionsSearchState> {
        switch action {
        case .select(let item):
            self.delegate?.sessionsSearchViewModel(self, wantsToShowSessionDetailsWith: item.id)
        case .search(let query):
            var filter = self.filter.value
            filter.query = query
            self.filter.value = filter
        case .filter:
            self.delegate?.sessionsSearchViewModel(self, wantsToShow: self.filter.value, completion: {[unowned self] filter in
                self.filter.value = filter
            })
        }
        let sessions = self.useCase.sessions
            .subscribeOn(Scheduler.backgroundWorkScheduler)
            .observeOn(Scheduler.mainScheduler)

        return Observable.combineLatest(sessions, self.filter.asObservable(), resultSelector: self.applyFilter)
            .map(SessionSectionViewModelBuilder.build)
            .map({ .loaded($0) })
            .asDriver(onErrorJustReturn: .error)
            .startWith(.loading)
    }

//    private func selectReducer(prevState: SessionsSearchState, item: SessionItemViewModel) -> SessionsSearchState {
//        self.delegate?.sessionsSearchViewModel(self, wantsToShowSessionDetailsWith: item.id)
//        return prevState
//    }
//
//    lazy var sessionSections: Driver<[SessionSectionViewModel]> = {
//        return Observable.combineLatest(self.useCase.sessions, self.filter.asObservable(), resultSelector: self.applyFilter)
//            .map(SessionSectionViewModelBuilder.build)
//            .asDriver(onErrorJustReturn: [])
//    }()
//
//    var isLoading: Driver<Bool> {
//        return self.activityIndicator.asDriver()
//    }
//
//    func didSelect(item: SessionItemViewModel) {
//        self.delegate?.sessionsSearchViewModel(self, wantsToShowSessionDetailsWith: item.id)
//    }
//
//    func didTapFilter() {
//        self.delegate?.sessionsSearchViewModel(self, wantsToShow: self.filter.value, completion: {[unowned self] filter in
//            self.filter.value = filter
//        })
//    }
//
//    func didStartSearch(withQuery query: String) {
//        var filter = self.filter.value
//        filter.query = query
//        self.filter.value = filter
//    }

    // MARK: Private

    private func applyFilter(sessions: [Session], filter: Filter) -> [Session] {
        return sessions.apply(filter)
    }

}
