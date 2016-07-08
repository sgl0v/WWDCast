//
//  SessionsDetailsInteractorImpl.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 06/07/16.
//  Copyright © 2016 Maksym Shcheglov. All rights reserved.
//

import Foundation

class SessionDetailsInteractorImpl {
    weak var presenter: SessionDetailsPresenter!
    let sessionId: String

    init(presenter: SessionDetailsPresenter, sessionId: String) {
        self.presenter = presenter
        self.sessionId = sessionId
    }
}

extension SessionDetailsInteractorImpl: SessionDetailsInteractor {

}
