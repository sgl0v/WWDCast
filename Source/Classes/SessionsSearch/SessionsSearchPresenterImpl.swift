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

    func updateView() {
        self.view.setTitle(Titles.SessionsSearchViewTitle)
        let subscription = self.interactor
            .loadSessions()
            .catchErrorJustReturn([])
            .map(self.createSessionViewModels)
            .subscribeNext {[unowned self] sessions in
//                print(sessions)
                self.view.showSessions(sessions)
        }
        subscription.addDisposableTo(self.disposeBag)
    }

    func selectItem(atIndex index: Int) {
        let subscription = self.interactor
            .loadSessions()
            .map({ sessions in return sessions[index] })
            .subscribeNext {[unowned self] session in
                self.interactor.playSession(session)
//                self.router.showSessionDetails(withId: session.uniqueId)
        }
        subscription.addDisposableTo(self.disposeBag)
    }

    // MARK: Private

    private func createSessionViewModels(sessions: [Session]) -> SessionViewModels {
//        print(sessions)
        return sessions.map() { session in
            return SessionViewModel(title: session.title, summary: session.summary, thumbnailURL: session.shelfImageURL)
        }
    }

}
