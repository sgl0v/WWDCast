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
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
            let handler =  {[unowned self] (action: UIAlertAction) in
                guard let idx = alert.actions.indexOf(action) else {
                    return
                }
                let device = Observable.just(self.interactor.devices[idx])
                Observable.combineLatest(device, self.interactor.session, resultSelector: { ($0, $1) })
                    .flatMap(self.interactor.playSession).subscribeNext({ _ in
                    
                }).addDisposableTo(self.disposeBag)
            }
            for device in self.interactor.devices {
                let playOnDeviceAction = UIAlertAction(title: device.name, style: .Default, handler: handler)
                alert.addAction(playOnDeviceAction)
            }
            let cancelButton = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) { _ in
                print("Cancel Pressed")
            }

            alert.addAction(cancelButton)
            let ctrl = UIApplication.sharedApplication().delegate?.window!?.rootViewController
            ctrl!.presentViewController(alert, animated: true, completion: nil)
        }
    }

}
