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
        let network = self.loadConfig().flatMapLatest(self.loadSessions)
            .retryOnBecomesReachable([], reachabilityService: self.serviceProvider.reachability)
            .subscribeOn(self.serviceProvider.scheduler.backgroundWorkScheduler)
            .observeOn(self.serviceProvider.scheduler.mainScheduler)
            .doOnNext(self.sessionsCache.save)
        let cache = self.sessionsCache.sessions
        
        return Observable.of(cache, network).merge().shareReplayLatestWhileConnected()
        
        //        self.router.showAlert(nil, message: NSLocalizedString("Failed to load WWDC sessions!", comment: ""))
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
        return self.sessions.map(filterFavoriteSessions)
    }
    
    private func filterFavoriteSessions(sessions: [Session]) -> [Session] {
        return sessions.filter({ session -> Bool in
            return session.favorite
        })
    }
    
    func addToFavorites(session: Session) {
        let newSession = SessionImpl(id: session.id, year: session.year, track: session.track, platforms: session.platforms, title: session.title, summary: session.summary, video: session.video, captions: session.captions, thumbnail: session.thumbnail, favorite: true)

        self.sessionsCache.update([newSession])
    }
    
    func removeFromFavorites(session: Session) {
        let newSession = SessionImpl(id: session.id, year: session.year, track: session.track, platforms: session.platforms, title: session.title, summary: session.summary, video: session.video, captions: session.captions, thumbnail: session.thumbnail, favorite: false)
        
        self.sessionsCache.update([newSession])
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
        
//    private var cachedSessions = Variable([Session]())
//
//    private func saveToCache(sessions: [Session]) {
//        do {
//            try SessionRecord.create(self.serviceProvider.database)
//            let records = sessions.map() { SessionRecord(session: $0) }
//            try self.serviceProvider.database.delete(records)
//            try self.serviceProvider.database.insert(records)
//        } catch {
//            NSLog("Failed to save sessions with error: \(error).")
//        }
//        
//        print("\(sessions)");
//        self.cachedSessions.value = loadFromCache()
//    }
//    
//    private func update(cachedSession session: Session) {
//        do {
//            let record = SessionRecord(session: session)
//            try self.serviceProvider.database.update([record])
//        } catch {
//            NSLog("Failed to update cached session with error: \(error).")
//        }
//        self.cachedSessions.value = loadFromCache()
//    }
//    
//    private func loadFromCache() -> [Session] {
//        let records: [SessionRecord] = self.serviceProvider.database.fetch()
//        let sessions = records.map() { session in
//            return session.session
//        }
////        NSLog("%@", sessions.description);
//        return sessions
//    }
    
}
