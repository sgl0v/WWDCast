//
//  SessionDetailsUseCase.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 01/12/2017.
//  Copyright © 2017 Maksym Shcheglov. All rights reserved.
//

import Foundation
import RxSwift

protocol SessionsDetailsUseCaseType {

    /// Currently available google cast devices
    var devices: Observable<[GoogleCastDevice]> { get }

    /// The current session
    var session: Observable<Session> { get }

    /// Starts the session playback on specified device
    func play(on device: GoogleCastDevice) -> Observable<Void>

    /// Toggles favorite session.
    var toggle: Observable<Void> { get }
}

class SessionsDetailsUseCase: SessionsDetailsUseCaseType {

    private let sessionId: String
    private let googleCast: GoogleCastServiceType
    private let dataSource: AnyDataSource<Session>

    init(sessionId: String, googleCast: GoogleCastServiceType, dataSource: AnyDataSource<Session>) {
        self.sessionId = sessionId
        self.googleCast = googleCast
        self.dataSource = dataSource
    }

    lazy var session: Observable<Session> = {
        return self.dataSource.get(byId: self.sessionId)
    }()

    var devices: Observable<[GoogleCastDevice]> {
        return self.googleCast.devices
    }

    func play(on device: GoogleCastDevice) -> Observable<Void> {
        return Observable.just(device).withLatestFrom(self.session).flatMap({ session -> Observable<Void> in
            let media = GoogleCastMedia(id: session.id, title: session.title, subtitle: session.subtitle, thumbnail: session.thumbnail, video: session.video.absoluteString, captions: session.captions?.absoluteString)
            return self.googleCast.play(media: media, onDevice: device)
        })
    }

    var toggle: Observable<Void> {
        return self.session.take(1).map({ session in
            let newSession = Session(id: session.id, contentId: session.contentId, type: session.type, year: session.year, track: session.track, platforms: session.platforms, title: session.title, summary: session.summary, video: session.video, captions: session.captions, duration: session.duration, thumbnail: session.thumbnail, favorite: !session.favorite)
            return [newSession]
        })
            .flatMap(self.dataSource.update)
            .mapToVoid()
    }

}
