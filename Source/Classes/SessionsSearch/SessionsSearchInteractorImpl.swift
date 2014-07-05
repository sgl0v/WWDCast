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

struct AppConfig {
    var sessionsURL = ""
    var videosURL = ""
    var isWWDCWeek = false
    var scheduleEnabled = false
    var shouldIgnoreCache = false
    var videosUpdatedAt = ""
}

struct Session {
    var uniqueId = ""
    var id = 0
    var year = 0
    var date = ""
    var track = ""
    var focus = ""
    var title = ""
    var summary = ""
    var videoURL = ""
    var hdVideoURL = ""
    var slidesURL = ""
    var shelfImageURL = ""
    var progress = 0.0
    var currentPosition: Double = 0.0
    var favorite = false
    var slidesPDFData = NSData()
    var downloaded = false

    var event: String {
        if id > 10000 {
            return "Apple TV Tech Talks"
        } else {
            return "WWDC"
        }
    }

    var isExtra: Bool {
        return event != "WWDC"
    }

    var shareURL: String {
        get {
            return "wwdc://\(year)/\(id)"
        }
    }

    var hd_url: String? {
        if hdVideoURL == "" {
            return nil
        } else {
            return hdVideoURL
        }
    }

    var subtitle: String {
        return "\(year) | \(track) | \(focus)"
    }

    func isSemanticallyEqualToSession(otherSession: Session) -> Bool {
        return id == otherSession.id &&
            year == otherSession.year &&
            date == otherSession.date &&
            track == otherSession.track &&
            focus == otherSession.focus &&
            title == otherSession.title &&
            summary == otherSession.summary &&
            videoURL == otherSession.videoURL &&
            hdVideoURL == otherSession.hdVideoURL &&
            slidesURL == otherSession.slidesURL
    }
}

protocol JSONAdapter {

    associatedtype ModelType

    static func adapt(json: JSON) -> ModelType

}

class AppConfigAdapter: JSONAdapter {

    typealias ModelType = AppConfig

    static func adapt(json: JSON) -> ModelType {
        var config = AppConfig()

        if let videos = json["urls"]["videos"].string {
            config.videosURL = videos
        }
        if let sessions = json["urls"]["sessions"].string {
            config.sessionsURL = sessions
        }

        if let streaming = json["features"]["liveStreaming"].bool {
            config.isWWDCWeek = streaming
        }

        config.scheduleEnabled = true
        config.shouldIgnoreCache = false
        
        return config
    }
    
}

class SessionAdapter: JSONAdapter {

    typealias ModelType = Session

    static func adapt(json: JSON) -> ModelType {
        var session = Session()

        session.id = json["id"].intValue
        session.year = json["year"].intValue
        session.uniqueId = "#" + String(session.year) + "-" + String(session.id)
        session.title = json["title"].stringValue
        session.summary = json["description"].stringValue
        session.date = json["date"].stringValue
        session.track = json["track"].stringValue
        session.videoURL = json["url"].stringValue
        session.hdVideoURL = json["download_hd"].stringValue
        session.slidesURL = json["slides"].stringValue
        session.track = json["track"].stringValue

        if let focus = json["focus"].arrayObject as? [String] {
            session.focus = focus.joinWithSeparator(", ")
        }

        if let images = json["images"].dictionaryObject as? [String: String] {
            session.shelfImageURL = images["shelf"] ?? ""
        }

        return session
    }

}

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
        return Observable<AnyObject>.create({ (observer) -> Disposable in
            let request = Alamofire.request(.GET, WWDCEnvironment.indexURL)
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
        }).map({ data in
            return AppConfigAdapter.adapt(JSON(data))
        })
    }

    private func loadSessions(config: AppConfig) -> Observable<[Session]> {
        return Observable<AnyObject>.create({ (observer) -> Disposable in
            let request = Alamofire.request(.GET, config.videosURL)
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
        }).map({ data in
//            let json = JSON(data)
//            print(json)
            return JSON(data)["sessions"].arrayValue.map() { sessionJSON in
                return SessionAdapter.adapt(sessionJSON)
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
