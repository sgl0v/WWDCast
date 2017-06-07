//
//  WWDCastAPIProtocolImpl.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 25/09/2016.
//  Copyright © 2016 Maksym Shcheglov. All rights reserved.
//

import Foundation
import RxSwift

class WWDCastAPI: WWDCastAPIProtocol {

    private let serviceProvider: ServiceProviderProtocol
    private var dataSource: AnyDataSource<Session>!

    init(serviceProvider: ServiceProviderProtocol) {
        self.serviceProvider = serviceProvider
//        self.cache = Cache(database: self.serviceProvider.database)

        if let coreDataController = CoreDataController(name: "WWDCast") {
            coreDataController.loadStore {[unowned self] err in
                print("Error=\(String(describing: err))")
                let cacheDataSource: AnyDataSource<Session> = AnyDataSource(dataSource: CoreDataSource<SessionManagedObject>(coreDataController: coreDataController))
                let networkDataSource: AnyDataSource<Session> = AnyDataSource(dataSource: NetworkDataSource(network: self.serviceProvider.network, reachability: self.serviceProvider.reachability))
                self.dataSource = AnyDataSource(dataSource: CompositeDataSource(networkDataSource: networkDataSource, coreDataSource: cacheDataSource))
            }
        }

//        createSessionsTableIfNeeded()
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

//        let cachedSessions = self.cache.values
//        let loadedSessions = self.loadConfig()
//            .flatMapLatest(self.loadSessions)
//            .retryOnBecomesReachable([], reachabilityService: self.serviceProvider.reachability)
//            .flatMap(self.updateCache)
//
//        return Observable.of(cachedSessions, loadedSessions)
//            .merge()
//            .sort()
//            .subscribeOn(self.serviceProvider.scheduler.backgroundWorkScheduler)
//            .observeOn(self.serviceProvider.scheduler.mainScheduler)
//            .shareReplayLatestWhileConnected()
    }()

    var favoriteSessions: Observable<[Session]> {
        return self.sessions.map({ sessions in
            return sessions.filter({ $0.favorite })
        })
    }

    func session(withId id: String) -> Observable<Session> {
        return self.dataSource.get(byId: id)
//        return self.sessions.flatMap({ sessions -> Observable<Session> in
//            if let session = sessions.filter({ session in
//                return session.uniqueId == id
//            }).first {
//                return Observable.just(session)
//            }
//            return Observable.empty()
//        })
    }

    func play(session: Session, onDevice device: GoogleCastDevice) -> Observable<Void> {
        guard let video = session.video?.absoluteString else {
            return Observable.error(GoogleCastServiceError.playbackError)
        }

        let media = GoogleCastMedia(id: session.id, title: session.title, subtitle: session.subtitle, thumbnail: session.thumbnail, video: video, captions: session.captions?.absoluteString)
        return self.serviceProvider.googleCast.play(media: media, onDevice: device)
    }

    func toggle(favoriteSession session: Session) -> Observable<Session> {
        let newSession = Session(id: session.id, year: session.year, track: session.track, platforms: session.platforms, title: session.title, summary: session.summary, video: session.video, captions: session.captions, thumbnail: session.thumbnail, favorite: !session.favorite)

        return self.dataSource.update([newSession]).flatMap(Observable.just(newSession))
    }

    // MARK: Private

//    private func loadConfig() -> Observable<AppConfig> {
//        guard let configResource = Resource(url: WWDCastEnvironment.configURL, parser: AppConfigBuilder.build) else {
//            return Observable.error(WWDCastAPIError.dataLoadingError)
//        }
//        return self.serviceProvider.network.load(configResource)
//    }
//
//    private func loadSessions(forConfig config: AppConfig) -> Observable<[Session]> {
//        guard let sessionsResource = Resource(url: config.videosURL, parser: SessionsBuilder.build) else {
//            return Observable.error(WWDCastAPIError.dataLoadingError)
//        }
//        return self.serviceProvider.network.load(sessionsResource)
//    }

//    private func createSessionsTableIfNeeded() {
//        if !self.serviceProvider.database.create(table: SessionTable.self) {
//            NSLog("Failed to create the sessions table!")
//        }
//    }

//    private func updateCache(sessions: [Session]) -> Observable<[Session]> {
//        return Observable.just(sessions).withLatestFrom(self.cache.values, resultSelector: { newSessions, cachedSessions in
//            let favoriteSessions = Set(cachedSessions.filter({ $0.favorite }).map({ $0.uniqueId }))
//            let sessionsToAdd = newSessions.map({ session in
//                return Session(id: session.id, year: session.year, track: session.track, platforms: session.platforms, title: session.title, summary: session.summary, video: session.video, captions: session.captions, thumbnail: session.thumbnail, favorite: favoriteSessions.contains(session.uniqueId))
//            })
//            if cachedSessions.isEmpty {
//                self.cache.add(values: sessionsToAdd)
//            } else {
//                self.cache.update(values: sessionsToAdd)
//            }
//            return sessionsToAdd
//        })
//    }

}
