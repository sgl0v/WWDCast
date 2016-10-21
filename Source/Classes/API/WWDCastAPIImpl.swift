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

    func sessions() -> Observable<[Session]> {
        let loadFromNetwork = loadConfig().flatMapLatest(self.loadSessions)
            .retryOnBecomesReachable([], reachabilityService: self.serviceProvider.reachability)
            .subscribeOn(self.serviceProvider.scheduler.backgroundWorkScheduler)
            .observeOn(self.serviceProvider.scheduler.mainScheduler)
            .shareReplayLatestWhileConnected()
            .doOnNext(self.saveToCache)
        let loadFromFile = self.loadFromCache()
        
        return Observable.of(loadFromFile, loadFromNetwork).concat().take(1).startWith([])
        
        //        self.router.showAlert(nil, message: NSLocalizedString("Failed to load WWDC sessions!", comment: ""))
    }
    
    func play(session: Session, onDevice device: GoogleCastDevice) -> Observable<Void> {
        return self.serviceProvider.googleCast.play(session, onDevice: device)
    }
    
    func addToFavorites(session: Session) -> Observable<Session> {
        var favoriteSessions = self.favoriteSessions()
        favoriteSessions.append(session.uniqueId)
        self.serviceProvider.cache.setObject(favoriteSessions, forKey: favoriteSessionsKey)
        
        return Observable.just(SessionImpl(id: session.id, year: session.year, track: session.track, platforms: session.platforms, title: session.title,
                           summary: session.summary, video: session.video, captions: session.captions,
                           thumbnail: session.thumbnail, favorite: true))
    }
    
    func removeFromFavorites(session: Session) -> Observable<Session> {
        var favoriteSessions = self.favoriteSessions()
        if let index = favoriteSessions.indexOf(session.uniqueId) {
            favoriteSessions.removeAtIndex(index)
        }
        self.serviceProvider.cache.setObject(favoriteSessions, forKey: favoriteSessionsKey)

        return Observable.just(SessionImpl(id: session.id, year: session.year, track: session.track, platforms: session.platforms, title: session.title,
                                  summary: session.summary, video: session.video, captions: session.captions,
                                  thumbnail: session.thumbnail, favorite: false))
    }

    // MARK: Private
    
    private func loadConfig() -> Observable<AppConfig> {
        return self.serviceProvider.network.request(WWDCEnvironment.indexURL, parameters: [:]).flatMap(build(AppConfigBuilder.self))
    }
    
    private func loadSessions(config: AppConfig) -> Observable<[Session]> {
        return self.serviceProvider.network.request(config.videosURL, parameters: [:]).flatMap(build(SessionsBuilder.self)).map(markFavoriteSessions)
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
    
    private func favoriteSessions() -> Array<String> {
        return self.serviceProvider.cache.objectForKey(favoriteSessionsKey) as? Array<String> ?? Array<String>()
    }
    
    private func markFavoriteSessions(sessions: [Session]) -> [Session] {
        let favoriteSessions = self.favoriteSessions()
        return sessions.map({ session in
            SessionImpl(id: session.id, year: session.year, track: session.track, platforms: session.platforms, title: session.title,
                summary: session.summary, video: session.video, captions: session.captions,
                thumbnail: session.thumbnail, favorite: favoriteSessions.contains(session.uniqueId))
        })
    }
    
    private func saveToCache(sessions: [Session]) {
//        NSLog("%@", sessions.description);
    }
    
    private func loadFromCache() -> Observable<[Session]> {
        return Observable.empty()
    }
    
}
