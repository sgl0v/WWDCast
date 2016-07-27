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
            .map(SessionViewModelBuilder.build)
            .asDriver(onErrorJustReturn: nil)
            .startWith(nil)
    }

    var playSession: AnyObserver<Void> {
        return AnyObserver {[unowned self] event in
            guard case .Next = event else {
                return
            }
            let subscription = self.interactor.session
                .bindTo(self.interactor.playSession)
            subscription.addDisposableTo(self.disposeBag)
        }
    }

}
