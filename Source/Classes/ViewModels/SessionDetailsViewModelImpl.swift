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
    private let sessionObservable: Observable<Session>
    private let favoriteTrigger = PublishSubject<Void>()

    init(sessionId: String, api: WWDCastAPI, router: SessionDetailsRouter) {
        self.api = api
        self.router = router
        let sessionObservable = self.api.session(withId: sessionId)
        let favoriteObservable = self.favoriteTrigger.withLatestFrom(sessionObservable).flatMap(self.api.toggle)
        self.sessionObservable = Observable.of(sessionObservable, favoriteObservable).merge()
    }

    // MARK: SessionDetailsViewModel

    let title = Driver.just(NSLocalizedString("Session Details", comment: "Session details view title"))

    lazy var session: Driver<SessionItemViewModel?> = {
        return self.sessionObservable.map(SessionItemViewModelBuilder.build).asDriver(onErrorJustReturn: nil)
    }()

    func didTapPlaySession() {
        let devices = self.api.devices
        if devices.isEmpty {
            self.router.showAlert(withTitle: nil, message: NSLocalizedString("Google Cast device is not found!", comment: ""))
            return
        }

        let actions = devices.map({ device in return device.description })
        let cancelAction = NSLocalizedString("Cancel", comment: "Cancel ActionSheet button title")
        let alert = self.router.showAlert(withTitle: nil, message: nil, cancelAction: cancelAction, actions: actions)
        let deviceObservable = alert.filter({ $0 != cancelAction })
            .map({ action in actions.index(of: action as String)! })
            .map({ idx in devices[idx] })
        Observable.combineLatest(self.sessionObservable, deviceObservable, resultSelector: { ($0, $1) })
            .take(1)
            .flatMap(self.api.play)
            .subscribe(onError: self.didFailToPlaySession)
            .addDisposableTo(self.disposeBag)
    }

    func didToggleFavorite() {
        self.favoriteTrigger.onNext()
    }

    // MARK: Private

    private func didFailToPlaySession(_ error: Error) {
        self.router.showAlert(withTitle: NSLocalizedString("Ooops...", comment: ""),
                              message: NSLocalizedString("Failed to play WWDC session.", comment: ""))
    }

}
