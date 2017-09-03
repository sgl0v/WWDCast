//
//  WWDCastAPIProtocolImpl.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 25/09/2016.
//  Copyright © 2016 Maksym Shcheglov. All rights reserved.
//

import Foundation
import RxSwift

/// The `WWDCastAPI` class implements `WWDCastAPIProtocol` and provides api to be used all over the app.
class WWDCastAPI: WWDCastAPIProtocol {

    private var dataSource: AnyDataSource<Session>!
    private let serviceProvider: ServiceProviderProtocol

    init(serviceProvider: ServiceProviderProtocol) {
        self.serviceProvider = serviceProvider
        let coreDataController = CoreDataController(name: "WWDCast")
        let cacheDataSource: AnyDataSource<Session> = AnyDataSource(dataSource: CoreDataSource<SessionManagedObject>(coreDataController: coreDataController))
        let networkDataSource: AnyDataSource<Session> = AnyDataSource(dataSource: NetworkDataSource(network: self.serviceProvider.network, reachability: self.serviceProvider.reachability))
        self.dataSource = AnyDataSource(dataSource: CompositeDataSource(networkDataSource: networkDataSource, coreDataSource: cacheDataSource))
    }

    // MARK: WWDCastAPIProtocol

    var devices: Observable<[GoogleCastDevice]> {
        return Observable.just(self.serviceProvider.googleCast.devices)
    }

    lazy var sessions: Observable<[Session]> = {
        return self.dataSource.allObjects()
            .subscribeOn(self.serviceProvider.scheduler.backgroundWorkScheduler)
            .observeOn(self.serviceProvider.scheduler.mainScheduler)
            .shareReplayLatestWhileConnected()
    }()

    var favoriteSessions: Observable<[Session]> {
        return self.sessions.map({ sessions in
            return sessions.filter({ $0.favorite })
        })
    }

    func session(withId id: String) -> Observable<Session> {
        return self.dataSource.get(byId: id)
    }

    func play(session: Session, onDevice device: GoogleCastDevice) -> Observable<Void> {
        guard let video = session.video?.absoluteString else {
            return Observable.error(GoogleCastServiceError.playbackError)
        }

        let media = GoogleCastMedia(id: session.id, title: session.title, subtitle: session.subtitle, thumbnail: session.thumbnail, video: video, captions: session.captions?.absoluteString)
        return self.serviceProvider.googleCast.play(media: media, onDevice: device)
    }

    func toggle(favoriteSession session: Session) -> Observable<Session> {
        let newSession = Session(id: session.id, contentId: session.contentId, type: session.type, year: session.year, track: session.track, platforms: session.platforms, title: session.title, summary: session.summary, video: session.video, captions: session.captions, duration: session.duration, thumbnail: session.thumbnail, favorite: !session.favorite)

        return self.dataSource.update([newSession]).flatMap(Observable.just(newSession))
    }

}
