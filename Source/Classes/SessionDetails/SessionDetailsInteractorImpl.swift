//
//  SessionsDetailsInteractorImpl.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 06/07/16.
//  Copyright © 2016 Maksym Shcheglov. All rights reserved.
//

import Foundation
import RxSwift

class SessionDetailsInteractorImpl {
    let serviceProvider: ServiceProvider
    let session: Observable<Session>

    init(session: Session, serviceProvider: ServiceProvider) {
        self.serviceProvider = serviceProvider
        self.session = Observable.just(session)
    }
}

extension SessionDetailsInteractorImpl: SessionDetailsInteractor {

    func playSession(device: GoogleCastDevice, session: Session) -> Observable<Void> {
        return self.serviceProvider.googleCast.play(session, onDevice: device)
    }

    var devices: [GoogleCastDevice] {
        return self.serviceProvider.googleCast.devices
    }

}
