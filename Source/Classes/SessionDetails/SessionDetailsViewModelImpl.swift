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

class SessionDetailsViewModelImpl: SessionDetailsViewModel {
    private let router: SessionDetailsRouter
    private let disposeBag = DisposeBag()
    private let api: WWDCastAPI
    private let _session: Variable<Session>

    init(session: Session, api: WWDCastAPI, router: SessionDetailsRouter) {
        self._session = Variable(session)
        self.api = api
        self.router = router
    }
    
    // MARK: SessionDetailsViewModel

    let title = Driver.just(Titles.SessionDetailsViewTitle)
    
    var session: Driver<SessionViewModel> {
        return self._session.asDriver().map(SessionViewModelBuilder.build)
    }
    
    func playSession() {
        let devices = self.api.devices
        if (devices.isEmpty) {
            self.router.showAlert(nil, message: NSLocalizedString("Google Cast device is not found!", comment: ""))
        }
        
        let actions = devices.map({ device in return device.description })
        let cancelAction = NSLocalizedString("Cancel", comment: "Cancel ActionSheet button title")
        let alert = self.router.promptFor(nil, message: nil, cancelAction: cancelAction, actions: actions)
        let deviceObservable = alert.filter({ $0 != cancelAction })
            .map({ action in actions.indexOf(action as String)! })
            .map({ idx in devices[idx] })
        Observable.combineLatest(self._session.asObservable(), deviceObservable, resultSelector: { ($0, $1) })
            .flatMap(self.api.play)
            .subscribeError(self.didFailToPlaySession)
            .addDisposableTo(self.disposeBag)
    }
    
    // MARK: Private
    
    private func didFailToPlaySession(error: ErrorType) {
        self.router.showAlert(NSLocalizedString("Ooops...", comment: ""), message: NSLocalizedString("Failed to play WWDC session.", comment: ""))
    }
    
}
