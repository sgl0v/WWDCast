//
//  SessionsDetailsPresenterImpl.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 06/07/16.
//  Copyright © 2016 Maksym Shcheglov. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class SessionDetailsPresenterImpl {
    weak var view: SessionDetailsView!
    var interactor: SessionDetailsInteractor!
    private let disposeBag = DisposeBag()

    init(view: SessionDetailsView) {
        self.view = view
    }
}

extension SessionDetailsPresenterImpl: SessionDetailsPresenter {

    var session: Driver<SessionViewModel?> {
        return self.interactor.session
            .map(self.createSessionViewModel)
            .asDriver(onErrorJustReturn: nil)
            .startWith(nil)
    }

    // MARK: Private

    func createSessionViewModel(session: Session) -> SessionViewModel {
        return SessionViewModel(uniqueID: session.uniqueId, title: session.title, summary: session.summary, thumbnailURL: session.shelfImageURL)
    }
}
