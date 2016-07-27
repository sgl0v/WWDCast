//
//  SessionsSearchPresenterImpl.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 04/07/16.
//  Copyright © 2016 Maksym Shcheglov. All rights reserved.
//

import Foundation
import RxSwift

struct Titles {
    static let SessionsSearchViewTitle = NSLocalizedString("WWDCast", comment: "Session search title")
}

class SessionsSearchPresenterImpl {
    weak var view: SessionsSearchView!
    var interactor: SessionsSearchInteractor!
    var router: SessionsSearchRouter
    private let disposeBag = DisposeBag()

    init(view: SessionsSearchView, router: SessionsSearchRouter) {
        self.view = view
        self.router = router
    }
}

extension SessionsSearchPresenterImpl: SessionsSearchPresenter {

    var updateView: AnyObserver<Void> {
        return AnyObserver {[unowned self] event in
            guard case .Next = event else {
                return
            }
            Observable.just(Titles.SessionsSearchViewTitle)
                .asDriver(onErrorJustReturn: "")
                .drive(self.view.titleText)
                .addDisposableTo(self.disposeBag)
            self.interactor
                .loadSessions()
                .map(SessionViewModelBuilder.build)
                .asDriver(onErrorJustReturn: [])
                .drive(self.view.showSessions)
                .addDisposableTo(self.disposeBag)
        }
    }

    var itemSelected: AnyObserver<SessionViewModel> {
        return AnyObserver {[unowned self] event in
            guard case .Next(let session) = event else {
                return
            }
//            let subscription = self.interactor
//                .loadSessions()
//                .map({ sessions in return sessions[index]})
//                .bindTo(self.interactor.playSession)
//            subscription.addDisposableTo(self.disposeBag)
            self.router.showSessionDetails(withId: session.uniqueID)
        }
    }

}
