//
//  MockWWDCastAPI.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 01/03/2017.
//  Copyright © 2017 Maksym Shcheglov. All rights reserved.
//

import Foundation
import RxSwift

class MockWWDCastAPI: WWDCastAPIProtocol {

    typealias DevicesObservable = Observable<[GoogleCastDevice]>
    typealias SessionsObservable = Observable<[Session]>
    typealias FavoritesObservable = Observable<[Session]>
    typealias SessionObservable = (String) -> Observable<Session>
    typealias PlayObservable = (Session, GoogleCastDevice) -> Observable<Void>
    typealias ToggleObservable = (Session) -> Observable<Session>

    var devicesObservable: DevicesObservable?
    var sessionsObservable: SessionsObservable?
    var favoritesObservable: FavoritesObservable?
    var sessionObservable: SessionObservable?
    var playObservable: PlayObservable?
    var toggleObservable: ToggleObservable?

    var devices: Observable<[GoogleCastDevice]> {
        guard let observable = self.devicesObservable else {
            fatalError("Not implemented")
        }
        return observable
    }

    var sessions: Observable<[Session]> {
        guard let observable = self.sessionsObservable else {
            fatalError("Not implemented")
        }
        return observable
    }

    var favoriteSessions: Observable<[Session]> {
        guard let observable = self.favoritesObservable else {
            fatalError("Not implemented")
        }
        return observable
    }

    func session(withId id: String) -> Observable<Session> {
        guard let observable = self.sessionObservable else {
            fatalError("Not implemented")
        }
        return observable(id)
    }

    func play(session: Session, onDevice device: GoogleCastDevice) -> Observable<Void> {
        guard let observable = self.playObservable else {
            fatalError("Not implemented")
        }
        return observable(session, device)
    }

    func toggle(favoriteSession session: Session) -> Observable<Session> {
        guard let observable = self.toggleObservable else {
            fatalError("Not implemented")
        }
        return observable(session)
    }
}
