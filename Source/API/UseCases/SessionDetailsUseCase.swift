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

    /// The list of currently available google cast devices
    var devices: Observable<[GoogleCastDevice]> { get }

    /// Provides session for specified identifier.
    func session(withId id: String) -> Observable<Session>

    /// Starts the session playback on specified device
    func play(session: Session, on device: GoogleCastDevice) -> Observable<Void>

    /// Toggles favorite session.
    func toggle(favoriteSession session: Session) -> Observable<Session>
}

class SessionsDetailsUseCase: SessionsDetailsUseCaseType {

    private let googleCast: GoogleCastServiceType
    private let dataSource: AnyDataSource<Session>

    init(googleCast: GoogleCastServiceType, dataSource: AnyDataSource<Session>) {
        self.googleCast = googleCast
        self.dataSource = dataSource
    }

    func session(withId id: String) -> Observable<Session> {
        return self.dataSource.get(byId: id)
    }

    var devices: Observable<[GoogleCastDevice]> {
        return Observable.just(self.googleCast.devices)
    }

    func play(session: Session, on device: GoogleCastDevice) -> Observable<Void> {
        guard let video = session.video?.absoluteString else {
            return Observable.error(GoogleCastServiceError.playbackError)
        }

        let media = GoogleCastMedia(id: session.id, title: session.title, subtitle: session.subtitle, thumbnail: session.thumbnail, video: video, captions: session.captions?.absoluteString)
        return self.googleCast.play(media: media, onDevice: device)
    }

    func toggle(favoriteSession session: Session) -> Observable<Session> {
        let newSession = Session(id: session.id, contentId: session.contentId, type: session.type, year: session.year, track: session.track, platforms: session.platforms, title: session.title, summary: session.summary, video: session.video, captions: session.captions, duration: session.duration, thumbnail: session.thumbnail, favorite: !session.favorite)

        return self.dataSource.update([newSession]).flatMap(Observable.just(newSession))
    }

}
