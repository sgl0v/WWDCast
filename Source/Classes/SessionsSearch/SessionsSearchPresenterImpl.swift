//
//  SessionsSearchPresenterImpl.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 04/07/16.
//  Copyright © 2016 Maksym Shcheglov. All rights reserved.
//

import Foundation

class SessionsSearchPresenterImpl {
    weak var view: SessionsSearchView!
    var interactor: SessionsSearchInteractor!

    init(view: SessionsSearchView) {
        self.view = view
    }
}

extension SessionsSearchPresenterImpl: SessionsSearchPresenter {

    func updateView() {
        _ = self.interactor
            .loadSessions()
            .map({ sessions in
                return sessions.map() { session in
                    return SessionViewModel(title: session.title, summary: session.summary, shelfImageURL: session.shelfImageURL)
                }
            })
            .subscribeNext { sessions in
                print(sessions)
        }
    }
}