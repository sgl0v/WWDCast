//
//  WWDCastAPIProtocol.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 25/09/2016.
//  Copyright © 2016 Maksym Shcheglov. All rights reserved.
//

import Foundation
import RxSwift

/// Defines the API errors.
enum WWDCastAPIError: Error {
    /// Failed to load data from the network.
    case dataLoadingError
}

/// The `WWDCastAPIProtocol` protocol defines api to be used all over the app.
protocol WWDCastAPIProtocol: class {

    /// The list of currently available google cast devices
    var devices: Observable<[GoogleCastDevice]> { get }

    /// The sequence of WWDC Sessions
    var sessions: Observable<[Session]> { get }

    /// The sequence of favorite WWDC Sessions
    var favoriteSessions: Observable<[Session]> { get }

    /// Provides session for specified identifier.
    func session(withId id: String) -> Observable<Session>

    /// Starts the session playback on specified device
    func play(session: Session, onDevice device: GoogleCastDevice) -> Observable<Void>

    /// Toggles favorite session.
    func toggle(favoriteSession session: Session) -> Observable<Session>

}
