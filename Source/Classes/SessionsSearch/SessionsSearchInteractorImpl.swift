//
//  SessionsSearchInteractorImpl.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 04/07/16.
//  Copyright © 2016 Maksym Shcheglov. All rights reserved.
//

import Foundation
import Alamofire
import RxSwift
import SwiftyJSON

class SessionsSearchInteractorImpl {
    var presenter: SessionsSearchPresenter
    let disposeBag = DisposeBag()

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
    }

    private func loadConfig() -> Observable<AppConfig> {
        return rx_request(.GET, WWDCEnvironment.indexURL).map({ data in
            return AppConfigBuilder.build(JSON(data))
        })
    }

    private func loadSessions(config: AppConfig) -> Observable<[Session]> {
        return rx_request(.GET, config.sessionsURL).map({ data in
//            let json = JSON(data)
//            print(json)
            return JSON(data)["sessions"].arrayValue.map() { sessionJSON in
                return SessionBuilder.build(sessionJSON)
            }

//            // create and store/update each video
//            for jsonSession in sessionsArray {
//                // ignored videos from 2016 without a duration specified
//                if jsonSession["duration"].intValue == 0 && jsonSession["year"].intValue > 2015 { continue }
//
//                let session = SessionAdapter.adapt(jsonSession)
//            }
        })
    }

}

func rx_request(method: Alamofire.Method, _ URLString: URLStringConvertible) -> Observable<AnyObject> {
    return Observable<AnyObject>.create({ (observer) -> Disposable in
        let request = Alamofire.request(method, URLString)
            .responseJSON(completionHandler: { (firedResponse) -> Void in
                if let value = firedResponse.result.value {
                    observer.onNext(value)
                    observer.onCompleted()
                } else if let error = firedResponse.result.error {
                    observer.onError(error)
                }
            })
        return AnonymousDisposable {
            request.cancel()
        }
    })
}
