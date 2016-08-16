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
    var interactor: SessionDetailsInteractor!
    private weak var view: SessionDetailsView!
    private var router: SessionDetailsRouter!
    private let disposeBag = DisposeBag()
    let isPlaying = Variable(false)

    init(view: SessionDetailsView, router: SessionDetailsRouter) {
        self.view = view
        self.router = router
    }
    
    private func playSession() -> Observable<Void> {
        let actions = self.interactor.devices.map({ device in return device.description })
        let cancelAction = NSLocalizedString("Cancel", comment: "Cancel ActionSheet button title")
        let alert = self.router.showAlert(nil, message: nil, style: .ActionSheet, cancelAction: cancelAction, actions: actions)
        let deviceObservable = alert.filter({ $0 != cancelAction })
            .map({ action in actions.indexOf(action as String)! })
            .map({ idx in self.interactor.devices[idx] })
        return Observable.combineLatest(deviceObservable, self.interactor.session, resultSelector: { ($0, $1) })
            .flatMap(self.interactor.playSession)
    }

}

extension SessionDetailsPresenterImpl: SessionDetailsPresenter {

    var session: Driver<SessionViewModel?> {
        return self.interactor.session
            .map(SessionViewModelBuilder.build)
            .asDriver(onErrorJustReturn: nil)
            .startWith(nil)
    }
    
    func onStart() {
        self.view.showSession.flatMap(self.playSession).subscribeNext({[unowned self] in
            self.isPlaying.value = true
        }).addDisposableTo(self.disposeBag)
    }
    
}
