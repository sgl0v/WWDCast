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
    var isLoading: Observable<Bool> {
        return _isLoading
    }
    private let _isLoading = BehaviorSubject(value: false);
    private let disposeBag = DisposeBag()

    init(view: SessionsSearchView, router: SessionsSearchRouter) {
        self.view = view
        self.router = router
        self.title = Driver.just(Titles.SessionsSearchViewTitle)
        self.sessions = view.searchQuery.flatMapLatest(self.sessionsSearch)
    }
    
    private func sessionsSearch(query: String) -> Driver<[SessionViewModels]> {
        return self.interactor
            .loadSessions()
            .asDriver(onErrorJustReturn: [])
            .map({ sessions in query.isEmpty ? sessions : sessions.filter({ elem in elem.title.containsString(query)}) })
            .map(SessionViewModelBuilder.build) // create viewModels & group them by track
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
    
    var filter: AnyObserver<Void> {
        return AnyObserver {[unowned self] event in
            guard case .Next = event else {
                return
            }
            self.router.showFilterController()
        }
    }

}
