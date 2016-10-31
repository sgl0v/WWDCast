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
    private let sessionsCache: SessionsCache
    
    init(serviceProvider: ServiceProvider, sessionsCache: SessionsCache) {
        self.serviceProvider = serviceProvider
        self.sessionsCache = sessionsCache
    }
    
    // MARK: WWDCastAPI
    
    var devices: [GoogleCastDevice] {
        return self.serviceProvider.googleCast.devices
    }

    lazy var sessions: Observable<[Session]> = {
        let cache = self.sessionsCache.sessions
        let network = self.loadConfig()
            .flatMapLatest(self.loadSessions)
            .retryOnBecomesReachable([], reachabilityService: self.serviceProvider.reachability)
            .doOnNext(self.sessionsCache.save)
            .flatMap({ _ in return cache })
        
        return Observable.of(cache, network)
            .merge()
            .subscribeOn(self.serviceProvider.scheduler.backgroundWorkScheduler)
            .observeOn(self.serviceProvider.scheduler.mainScheduler)
            .shareReplayLatestWhileConnected()
    }()
    
    func session(withId id: String) -> Observable<Session> {
        return self.sessions.map({ sessions in
            return sessions.filter({ session in
                return session.uniqueId == id
            }).first!
        })
    }
    
    func play(session: Session, onDevice device: GoogleCastDevice) -> Observable<Void> {
        return self.serviceProvider.googleCast.play(session, onDevice: device)
    }
    
    var favoriteSessions: Observable<[Session]> {
        return self.sessions.map({ sessions in
            return sessions.filter({ $0.favorite })
        })
    }
    
    func toggleFavorite(session: Session) -> Observable<Session> {
        let newSession = SessionImpl(id: session.id, year: session.year, track: session.track, platforms: session.platforms, title: session.title, summary: session.summary, video: session.video, captions: session.captions, thumbnail: session.thumbnail, favorite: !session.favorite)
        
        self.sessionsCache.update([newSession])
        return Observable.just(newSession)
    }

    // MARK: Private
    
    private func loadConfig() -> Observable<AppConfig> {
        return self.serviceProvider.network.request(WWDCEnvironment.indexURL, parameters: [:]).flatMap(build(AppConfigBuilder.self))
    }
    
    private func loadSessions(config: AppConfig) -> Observable<[Session]> {
        return self.serviceProvider.network.request(config.videosURL, parameters: [:]).flatMap(build(SessionsBuilder.self))
    }
    
    private func build<Builder: EntityBuilder>(builder: Builder.Type) -> NSData -> Observable<Builder.EntityType> {
        return { data in
            do {
                let entity = try builder.build(JSON(data: data))
                return Observable.just(entity)
            } catch let error {
                return Observable.error(error)
            }
        }
    }
    
}
