//
//  MockSessionDetailsUseCase.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 04/03/2018.
//  Copyright © 2018 Maksym Shcheglov. All rights reserved.
//

import Foundation
import RxSwift
@testable import WWDCast

class MockSessionDetailsUseCase: SessionDetailsUseCaseType {
    typealias DevicesObservable = Observable<[GoogleCastDevice]>
    typealias SessionObservable = Observable<Session>
    typealias PlayObservable = (GoogleCastDevice) -> Observable<Void>
    typealias ToggleObservable = Observable<Void>

    var devicesObservable: DevicesObservable?
    var sessionObservable: SessionObservable?
    var playObservable: PlayObservable?
    var toggleObservable: ToggleObservable?

    var devices: Observable<[GoogleCastDevice]> {
        guard let observable = self.devicesObservable else {
            fatalError("Not implemented")
        }
        return observable
    }

    var session: Observable<Session> {
        guard let observable = self.sessionObservable else {
            fatalError("Not implemented")
        }
        return observable
    }

    func play(on device: GoogleCastDevice) -> Observable<Void> {
        guard let observable = self.playObservable else {
            fatalError("Not implemented")
        }
        return observable(device)
    }

    var toggle: Observable<Void> {
        guard let observable = self.toggleObservable else {
            fatalError("Not implemented")
        }
        return observable
    }
}
