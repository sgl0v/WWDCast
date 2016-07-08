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

    init(presenter: SessionsSearchPresenter) {
        self.presenter = presenter
    }
}

extension SessionsSearchInteractorImpl: SessionsSearchInteractor {

    func loadSessions() -> Observable<[Session]> {
        return loadConfig().flatMapLatest({ appConfig -> Observable<[Session]> in
            return self.loadSessions(appConfig)
        })
            .subscribeOn(OperationQueueScheduler(operationQueue: NSOperationQueue()))
            .observeOn(MainScheduler.instance)
            .shareReplayLatestWhileConnected()
    }

    // MARK: Private

    private func loadConfig() -> Observable<AppConfig> {
        return rx_request(.GET, WWDCEnvironment.indexURL).map({ data in
            return AppConfigBuilder.build(JSON(data))
        })
    }

    private func loadSessions(config: AppConfig) -> Observable<[Session]> {
        return rx_request(.GET, config.videosURL).map({ data in
            return SessionsBuilder.build(JSON(data))
        })
    }

}
