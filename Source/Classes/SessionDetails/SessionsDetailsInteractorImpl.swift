//
//  SessionsDetailsInteractorImpl.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 06/07/16.
//  Copyright © 2016 Maksym Shcheglov. All rights reserved.
//

import Foundation
import RxSwift
import SwiftyJSON

class SessionDetailsInteractorImpl {
    weak var presenter: SessionDetailsPresenter!
    let serviceProvider: ServiceProvider
    let sessionId: String

    init(presenter: SessionDetailsPresenter, serviceProvider: ServiceProvider, sessionId: String) {
        self.presenter = presenter
        self.serviceProvider = serviceProvider
        self.sessionId = sessionId
    }
}

extension SessionDetailsInteractorImpl: SessionDetailsInteractor {

    var session: Observable<Session> {
        return loadConfig().flatMapLatest(self.loadSessions).map(self.filterSessions).map({ $0.first! })
            .subscribeOn(self.serviceProvider.scheduler.backgroundWorkScheduler)
            .observeOn(self.serviceProvider.scheduler.mainScheduler)
            .shareReplayLatestWhileConnected()
    }

    // MARK: Private

    private func filterSessions(sessions: [Session]) -> [Session] {
        return sessions.filter() {session in session.uniqueId == self.sessionId}
    }

    private func loadConfig() -> Observable<AppConfig> {
        return loadData(WWDCEnvironment.indexURL, builder: AppConfigBuilder.self)
    }

    private func loadSessions(config: AppConfig) -> Observable<[Session]> {
        return loadData(config.videosURL, builder: SessionsBuilder.self)
    }

    private func loadData<Builder: EntityBuilder>(url: NSURL, builder: Builder.Type) -> Observable<Builder.EntityType> {
        return self.serviceProvider.network.GET(url, parameters: [:]).map() { data in
            return builder.build(JSON(data: data))
        }
    }

}
