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
    static let SessionsSearchViewTitle = NSLocalizedString("WWDCast", comment: "Session search title")
}

class SessionsSearchPresenterImpl {
    weak var view: SessionsSearchView!
    var interactor: SessionsSearchInteractor!
    var router: SessionsSearchRouter
    var sessions: Driver<[SessionViewModels]>!
    var isLoading: Observable<Bool> {
        return _isLoading
    }
    private let _isLoading = BehaviorSubject(value: false);
    private let disposeBag = DisposeBag()

    init(view: SessionsSearchView, router: SessionsSearchRouter) {
        self.view = view
        self.router = router
        self.sessions = view.searchQuery.flatMapLatest ({ query in
            return self.interactor
                .loadSessions()
                .map({ sessions in query.isEmpty ? sessions : sessions.filter({ elem in elem.title.containsString(query)}) })
                .map(SessionViewModelBuilder.build)
        }).asDriver(onErrorJustReturn: [])
    }

}

extension SessionsSearchPresenterImpl: SessionsSearchPresenter {

    var updateView: AnyObserver<String> {
        return AnyObserver {[unowned self] event in
            guard case .Next(let query) = event else {
                return
            }
            Observable.just(Titles.SessionsSearchViewTitle)
                .asDriver(onErrorJustReturn: "")
                .drive(self.view.titleText)
                .addDisposableTo(self.disposeBag)
//            self.interactor
//                .loadSessions()
//                .map(SessionViewModelBuilder.build)
//                .asDriver(onErrorJustReturn: [])
//                .map({ sessions in query.isEmpty ? sessions : sessions.filter({ elem in elem.title.containsString(query)}) })
//                .drive(self.view.showSessions)
//                .addDisposableTo(self.disposeBag)
        }
    }

    var itemSelected: AnyObserver<SessionViewModel> {
        return AnyObserver {[unowned self] event in
            guard case .Next(let session) = event else {
                return
            }
            self.router.showSessionDetails(withId: session.uniqueID)
        }
    }

}
