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
    private let serviceProvider: ServiceProvider
    private let _session: Variable<Session>
    
    let isPlaying = Variable(false)

    init(session: Session, serviceProvider: ServiceProvider, router: SessionDetailsRouter) {
        self._session = Variable(session)
        self.serviceProvider = serviceProvider
        self.router = router
    }
    
    // MARK: SessionDetailsViewModel

    let title = Driver.just(Titles.SessionDetailsViewTitle)
    
    var session: Driver<SessionViewModel?> {
        return self._session.asDriver().map(SessionViewModelBuilder.build)
    }
    
    func playSession() {
        let actions = self.devices.map({ device in return device.description })
        let cancelAction = NSLocalizedString("Cancel", comment: "Cancel ActionSheet button title")
        let alert = self.router.promptFor(nil, message: nil, cancelAction: cancelAction, actions: actions)
        let deviceObservable = alert.filter({ $0 != cancelAction })
            .map({ action in actions.indexOf(action as String)! })
            .map({ idx in self.devices[idx] })
        Observable.combineLatest(self._session.asObservable(), deviceObservable, resultSelector: { ($0, $1) })
            .flatMap(self.serviceProvider.googleCast.play)
            .doOnError(self.didFailToPlaySession)
            .subscribeNext({ [unowned self] in self.isPlaying.value = true })
            .addDisposableTo(self.disposeBag)
    }
    
    // MARK: Private
    
    private var devices: [GoogleCastDevice] {
        return self.serviceProvider.googleCast.devices
    }
    
    private func didFailToPlaySession(error: ErrorType) {
        self.router.showAlert("Ooops...", message: "Failed to play WWDC session.")
    }
    
}
