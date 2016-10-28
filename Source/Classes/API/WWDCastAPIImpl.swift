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
    private let favoriteSessionsKey = "FavoriteSessions"
    
    init(serviceProvider: ServiceProvider) {
        self.serviceProvider = serviceProvider
    }
    
    // MARK: WWDCastAPI
    
    var devices: [GoogleCastDevice] {
        return self.serviceProvider.googleCast.devices
    }

    lazy var sessions: Observable<[Session]> = {
        let loadFromNetwork = self.loadConfig().flatMapLatest(self.loadSessions)
            .retryOnBecomesReachable([], reachabilityService: self.serviceProvider.reachability)
            .subscribeOn(self.serviceProvider.scheduler.backgroundWorkScheduler)
            .observeOn(self.serviceProvider.scheduler.mainScheduler)
            .doOnNext(self.saveToCache)
        let loadFromCache = self.loadFromCache()
        
        return Observable.of(loadFromCache, loadFromNetwork).merge().shareReplayLatestWhileConnected()
        
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
        var cachedSessions = self.cachedSessions.value
        guard let idx = cachedSessions.indexOf({ $0.uniqueId == session.uniqueId }) else {
            return
        }
        cachedSessions.removeAtIndex(idx)
        let newSession = SessionImpl(id: session.id, year: session.year, track: session.track, platforms: session.platforms, title: session.title, summary: session.summary, video: session.video, captions: session.captions, thumbnail: session.thumbnail, favorite: true)
        cachedSessions.insert(newSession, atIndex: idx)
        self.cachedSessions.value = cachedSessions
    }
    
    func removeFromFavorites(session: Session) {
        var cachedSessions = self.cachedSessions.value
        guard let idx = cachedSessions.indexOf({ $0.uniqueId == session.uniqueId }) else {
            return
        }
        cachedSessions.removeAtIndex(idx)
        let newSession = SessionImpl(id: session.id, year: session.year, track: session.track, platforms: session.platforms, title: session.title, summary: session.summary, video: session.video, captions: session.captions, thumbnail: session.thumbnail, favorite: false)
        cachedSessions.insert(newSession, atIndex: idx)
        self.cachedSessions.value = cachedSessions
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
    
//    private func favoriteSessions() -> Array<String> {
//        return self.serviceProvider.cache.objectForKey(favoriteSessionsKey) as? Array<String> ?? Array<String>()
//    }
    
//    private func markFavoriteSessions(sessions: [Session]) -> [Session] {
//        let favoriteSessions = self.favoriteSessions()
//        return sessions.map({ session in
//            SessionImpl(id: session.id, year: session.year, track: session.track, platforms: session.platforms, title: session.title,
//                summary: session.summary, video: session.video, captions: session.captions,
//                thumbnail: session.thumbnail, favorite: favoriteSessions.contains(session.uniqueId))
//        })
//    }
    
    private var cachedSessions = Variable([Session]())
    
    private func saveToCache(sessions: [Session]) {
        self.cachedSessions.value = sessions
//        NSLog("%@", sessions.description);
    }
    
    private func loadFromCache() -> Observable<[Session]> {
//        return Observable.empty()
        return self.cachedSessions.asObservable()
    }
    
}
