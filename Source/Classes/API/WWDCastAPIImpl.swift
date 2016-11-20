//
//  WWDCastAPIImpl.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 25/09/2016.
//  Copyright © 2016 Maksym Shcheglov. All rights reserved.
//

import Foundation
import RxSwift
import SwiftyJSON

class WWDCastAPIImpl : WWDCastAPI {
    
    private let serviceProvider: ServiceProvider
    private let cache: Cache<Session>
    
    init(serviceProvider: ServiceProvider) {
        self.serviceProvider = serviceProvider
        self.cache = Cache(db: self.serviceProvider.database)
        createSessionsTableIfNeeded()
    }
    
    // MARK: WWDCastAPI
    
    var devices: [GoogleCastDevice] {
        return self.serviceProvider.googleCast.devices
    }

    lazy var sessions: Observable<[Session]> = {
        let cachedSessions = self.cache.values
        let loadedSessions = self.loadConfig()
            .flatMapLatest(self.loadSessions)
            .retryOnBecomesReachable([], reachabilityService: self.serviceProvider.reachability)
            .flatMap(self.updateCache)
        
        return Observable.of(cachedSessions, loadedSessions)
            .merge()
            .map(self.sortSessions)
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
        return self.sessions.flatMap({ sessions -> Observable<Session> in
            if let session = sessions.filter({ session in
                return session.uniqueId == id
            }).first {
                return Observable.just(session)
            }
            return Observable.empty()
        })
    }
    
    func play(session: Session, onDevice device: GoogleCastDevice) -> Observable<Void> {
        guard let video = session.video?.absoluteString else {
            return Observable.error(GoogleCastServiceError.playbackError)
        }
        
        let media = GoogleCastMedia(id: session.id, title: session.title, subtitle: session.subtitle, thumbnail: session.thumbnail, video: video, captions: session.captions?.absoluteString)
        return self.serviceProvider.googleCast.play(media, onDevice: device)
    }
    
    func toggle(favoriteSession session: Session) -> Observable<Session> {
        let newSession = Session(id: session.id, year: session.year, track: session.track, platforms: session.platforms, title: session.title, summary: session.summary, video: session.video, captions: session.captions, thumbnail: session.thumbnail, favorite: !session.favorite)
        
        self.cache.update(values: [newSession])
        return Observable.just(newSession)
    }

    // MARK: Private
    
    private func loadConfig() -> Observable<AppConfig> {
        return self.serviceProvider.network.request(WWDCEnvironment.indexURL, parameters: [:]).flatMap(build(AppConfigBuilder.self))
    }
    
    private func loadSessions(_ config: AppConfig) -> Observable<[Session]> {
        return self.serviceProvider.network.request(config.videosURL, parameters: [:]).flatMap(build(SessionsBuilder.self))
    }
    
    private func build<Builder: EntityBuilder>(_ builder: Builder.Type) -> (Data) -> Observable<Builder.EntityType> {
        return { data in
            do {
                let entity = try builder.build(JSON(data: data))
                return Observable.just(entity)
            } catch let error {
                return Observable.error(error)
            }
        }
    }
    
    private func sortSessions(_ sessions: [Session]) -> [Session] {
        return sessions.sorted(by: { lhs, rhs in
            return lhs.id < rhs.id && lhs.year.rawValue >= rhs.year.rawValue
        })
    }
    
    private func createSessionsTableIfNeeded() {
        if !self.serviceProvider.database.create(table: SessionTable.self) {
            NSLog("Failed to create the sessions table!")
        }
    }
    
    private func updateCache(sessions: [Session]) -> Observable<[Session]> {
        return Observable.just(sessions).withLatestFrom(self.cache.values, resultSelector: { newSessions, cachedSessions in
            let favoriteSessions = Set(cachedSessions.filter({ $0.favorite }).map({ $0.uniqueId }))
            let sessionsToAdd = newSessions.map({ session in
                return Session(id: session.id, year: session.year, track: session.track, platforms: session.platforms, title: session.title, summary: session.summary, video: session.video, captions: session.captions, thumbnail: session.thumbnail, favorite: favoriteSessions.contains(session.uniqueId))
            })
            if (cachedSessions.isEmpty) {
                self.cache.add(values: sessionsToAdd)
            } else {
                self.cache.update(values: sessionsToAdd)
            }
            return sessionsToAdd
        })
    }
    
}
