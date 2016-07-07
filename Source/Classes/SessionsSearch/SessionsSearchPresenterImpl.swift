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
    private let disposeBag = DisposeBag()

    init(view: SessionsSearchView) {
        self.view = view
    }
}

extension SessionsSearchPresenterImpl: SessionsSearchPresenter {

    func updateView() {
        self.view.setTitle(Titles.SessionsSearchViewTitle)
        let subscription = self.interactor
            .loadSessions()
            .catchErrorJustReturn([])
            .map({ sessions in
                return sessions.map() { session in
                    return SessionViewModel(title: session.title, summary: session.summary, thumbnailURL: NSURL(string: session.shelfImageURL)!)
                }
            })
            .subscribeNext {[unowned self] sessions in
                self.view.showSessions(sessions)
//                print(sessions)
        }
        subscription.addDisposableTo(self.disposeBag)
    }

}