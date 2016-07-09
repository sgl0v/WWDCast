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
        return loadConfig().flatMapLatest({ appConfig -> Observable<[Session]> in
            return self.loadSessions(appConfig)
        })
            .subscribeOn(self.serviceProvider.schedulerService.backgroundWorkScheduler)
            .observeOn(self.serviceProvider.schedulerService.mainScheduler)
            .shareReplayLatestWhileConnected()
    }

    // MARK: Private

    private func loadConfig() -> Observable<AppConfig> {
        return loadData(WWDCEnvironment.indexURL, builder: AppConfigBuilder.self)
    }

    private func loadSessions(config: AppConfig) -> Observable<[Session]> {
        return loadData(config.videosURL, builder: SessionsBuilder.self)
    }

    private func loadData<Builder: EntityBuilder>(url: String, builder: Builder.Type) -> Observable<Builder.EntityType> {
        return self.serviceProvider.networkService.GET(url, parameters: [:]).map() { data in
            return builder.build(JSON(data: data))
        }
    }

}
