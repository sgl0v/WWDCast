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
    
    fileprivate let serviceProvider: ServiceProvider
    fileprivate let sessionsCache: SessionsCache
    
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
            .do(onNext: self.sessionsCache.save)
            .flatMap({ _ in return cache })
        
        return Observable.of(cache, network)
            .merge()
            .map(self.sortSessions)
            .subscribeOn(self.serviceProvider.scheduler.backgroundWorkScheduler)
            .observeOn(self.serviceProvider.scheduler.mainScheduler)
            .shareReplayLatestWhileConnected()
    }()
    
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
    
    func play(_ session: Session, onDevice device: GoogleCastDevice) -> Observable<Void> {
        return self.serviceProvider.googleCast.play(session, onDevice: device)
    }
    
    var favoriteSessions: Observable<[Session]> {
        return self.sessions.map({ sessions in
            return sessions.filter({ $0.favorite })
        })
    }
    
    func toggleFavorite(_ session: Session) -> Observable<Session> {
        let newSession = SessionImpl(id: session.id, year: session.year, track: session.track, platforms: session.platforms, title: session.title, summary: session.summary, video: session.video, captions: session.captions, thumbnail: session.thumbnail, favorite: !session.favorite)
        
        self.sessionsCache.update([newSession])
        return Observable.just(newSession)
    }

    // MARK: Private
    
    fileprivate func loadConfig() -> Observable<AppConfig> {
        return self.serviceProvider.network.request(WWDCEnvironment.indexURL, parameters: [:]).flatMap(build(AppConfigBuilder.self))
    }
    
    fileprivate func loadSessions(_ config: AppConfig) -> Observable<[Session]> {
        return self.serviceProvider.network.request(config.videosURL, parameters: [:]).flatMap(build(SessionsBuilder.self))
    }
    
    fileprivate func build<Builder: EntityBuilder>(_ builder: Builder.Type) -> (Data) -> Observable<Builder.EntityType> {
        return { data in
            do {
                let entity = try builder.build(JSON(data: data))
                return Observable.just(entity)
            } catch let error {
                return Observable.error(error)
            }
        }
    }
    
    fileprivate func sortSessions(_ sessions: [Session]) -> [Session] {
        return sessions.sorted(by: { lhs, rhs in
            return lhs.id < rhs.id && lhs.year.rawValue >= rhs.year.rawValue
        })
    }
    
}
