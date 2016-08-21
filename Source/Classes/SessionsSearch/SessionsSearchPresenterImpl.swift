//
//  SessionsSearchPresenterImpl.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 04/07/16.
//  Copyright © 2016 Maksym Shcheglov. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

struct Titles {
    static let SessionsSearchViewTitle = NSLocalizedString("WWDCast", comment: "Session search view title")
    static let SessionDetailsViewTitle = NSLocalizedString("Session Details", comment: "Session details view title")
}

class SessionsSearchPresenterImpl: SessionsSearchPresenter {
    weak var view: SessionsSearchView!
    var interactor: SessionsSearchInteractor!
    var router: SessionsSearchRouter
    var filter: Variable<Filter>
    var isLoading: Observable<Bool> {
        return _isLoading
    }
    private let _isLoading = BehaviorSubject(value: false);
    private let disposeBag = DisposeBag()

    init(view: SessionsSearchView, router: SessionsSearchRouter) {
        self.view = view
        self.router = router
        self.filter = Variable(Filter())
        self.title = Driver.just(Titles.SessionsSearchViewTitle)
        self.sessions = self.filter.asDriver().flatMapLatest(self.sessionsSearch)
//        self.sessions = view.searchQuery.driveNext({ query in
//            self.filter.value = 
//        })
    }
    
    private func sessionsSearch(filter: Filter) -> Driver<[SessionViewModels]> {
        return self.interactor
            .loadSessions()
            .asDriver(onErrorJustReturn: [])
            .map(self.applyFilter(filter))
            .map(SessionViewModelBuilder.build) // create viewModels & group them by track
    }
    
    private func applyFilter(filter: Filter) -> [Session] -> [Session] {
        return { sessions in
            sessions.filter { session in
                (filter.query.isEmpty || session.title.containsString(filter.query)) &&
                    filter.tracks.contains(session.track) &&
                    !Set(filter.platforms).intersect(session.platforms).isEmpty
            }
        }
    }
    
    // MARK: SessionsSearchPresenter
    
    var sessions: Driver<[SessionViewModels]>!
    let title: Driver<String>

    var itemSelected: AnyObserver<SessionViewModel> {
        return AnyObserver {[unowned self] event in
            guard case .Next(let session) = event else {
                return
            }
            self.router.showSessionDetails(withId: session.uniqueID)
        }
    }
    
    var filterObserver: AnyObserver<Void> {
        return AnyObserver {[unowned self] event in
            guard case .Next = event else {
                return
            }
            self.router.showFilterController(withFilter: self.filter.value) {[unowned self] filter in
                self.filter.value = filter
            }
        }
    }

}
