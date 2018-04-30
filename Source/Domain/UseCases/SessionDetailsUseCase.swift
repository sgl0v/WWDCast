//
//  SessionDetailsUseCase.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 01/12/2017.
//  Copyright © 2017 Maksym Shcheglov. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

protocol SessionDetailsUseCaseType {

    /// Currently available google cast devices
    var devices: Observable<[GoogleCastDevice]> { get }

    /// The current session
    var session: Observable<Session> { get }

    /// Starts the session playback on specified device
    func play(on device: GoogleCastDevice) -> Observable<Void>

    /// Toggles favorite session.
    var toggle: Observable<Void> { get }

    // Loads image for the given URL
    func loadImage(for url: URL) -> Observable<UIImage>
}

class SessionDetailsUseCase: SessionDetailsUseCaseType {

    enum Error: Swift.Error {
        case itemNotFound
    }

    private let sessionId: String
    private let googleCast: GoogleCastServiceType
    private let sessionsRepository: AnyRepository<[Session]>
    private let imageLoader: ImageLoaderServiceType

    init(sessionId: String, googleCast: GoogleCastServiceType, sessionsRepository: AnyRepository<[Session]>, imageLoader: ImageLoaderServiceType) {
        self.sessionId = sessionId
        self.googleCast = googleCast
        self.sessionsRepository = sessionsRepository
        self.imageLoader = imageLoader
    }

    lazy var session: Observable<Session> = {
        return self.sessionsRepository.asObservable()
            .flatMap({ items -> Observable<Session> in
                let item = items.filter({ item in
                    return item.uid == self.sessionId
                }).first
                if let item = item {
                    return Observable.just(item)
                }
                return Observable.error(Error.itemNotFound)
            })
            .subscribeOn(Scheduler.backgroundWorkScheduler)
            .observeOn(Scheduler.mainScheduler)
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
            .flatMap(self.sessionsRepository.update)
            .mapToVoid()
            .subscribeOn(Scheduler.backgroundWorkScheduler)
            .observeOn(Scheduler.mainScheduler)
    }

    func loadImage(for url: URL) -> Observable<UIImage> {
        return self.imageLoader.loadImage(for: url)
    }

}
