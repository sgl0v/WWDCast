//
//  SessionsSearchInteractorImpl.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 04/07/16.
//  Copyright © 2016 Maksym Shcheglov. All rights reserved.
//

import Foundation
import RxSwift
import SwiftyJSON

class SessionsSearchInteractorImpl {
    weak var presenter: SessionsSearchPresenter!
    private let serviceProvider: ServiceProvider

    init(presenter: SessionsSearchPresenter, serviceProvider: ServiceProvider) {
        self.presenter = presenter
        self.serviceProvider = serviceProvider
    }
}

extension SessionsSearchInteractorImpl: SessionsSearchInteractor {

    func loadSessions() -> Observable<[Session]> {
        return loadConfig().flatMapLatest(self.loadSessions)
            .subscribeOn(self.serviceProvider.scheduler.backgroundWorkScheduler)
            .observeOn(self.serviceProvider.scheduler.mainScheduler)
            .shareReplayLatestWhileConnected()
    }

    // MARK: Private

    private func loadConfig() -> Observable<AppConfig> {
        return self.serviceProvider.network.GET(WWDCEnvironment.indexURL, parameters: [:], builder: AppConfigBuilder.self)
    }

    private func loadSessions(config: AppConfig) -> Observable<[Session]> {
        return self.serviceProvider.network.GET(config.videosURL, parameters: [:], builder: SessionsBuilder.self)
    }
}
