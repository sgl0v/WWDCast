//
//  GoogleCastServiceProtocolImpl.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 09/07/16.
//  Copyright © 2016 Maksym Shcheglov. All rights reserved.
//

import Foundation
import GoogleCast
import RxSwift
import RxCocoa

final class GoogleCastServiceProtocolImpl: NSObject, GoogleCastServiceProtocol {
    private let disposeBag = DisposeBag()
    private var context: GCKCastContext {
        return GCKCastContext.sharedInstance()
    }
    private var sessionManager: GCKSessionManager {
        return self.context.sessionManager
    }
    private var currentSession: GCKCastSession? {
        return self.sessionManager.currentCastSession
    }

    init(applicationID: String) {
        super.init()
        let options = GCKCastOptions(receiverApplicationID: applicationID)
        GCKCastContext.setSharedInstanceWith(options)
        self.enableLogging()
    }

    // MARK: GoogleCastServiceProtocol

    var devices: [GoogleCastDevice] {
        let discoveryManager = self.context.discoveryManager
        guard discoveryManager.hasDiscoveredDevices else {
            return []
        }
        return (0..<discoveryManager.deviceCount).map({ idx in
            return discoveryManager.device(at: idx)
        }).map({ device in
            return GoogleCastDevice(name: device.friendlyName ?? "Unknown", id: device.deviceID)
        })
    }

    func play(media: GoogleCastMedia, onDevice device: GoogleCastDevice) -> Observable<Void> {
        return Observable.just(device)
            .flatMap(self.startSession)
            .flatMap(self.loadMedia(media.gckMedia))
    }

    func pausePlayback() {
        guard let currentSession = self.currentSession else {
            return
        }
        currentSession.remoteMediaClient.pause()
    }

    func resumePlayback() {
        guard let currentSession = self.currentSession else {
            return
        }
        currentSession.remoteMediaClient.play()
    }

    func stopPlayback() {
        guard let currentSession = self.currentSession else {
            return
        }
        currentSession.remoteMediaClient.stop()
    }

    // MARK: Private

    private func device(withId id: String) -> GCKDevice? {
        return (0..<self.context.discoveryManager.deviceCount).map({ idx in
            return self.context.discoveryManager.device(at: idx)
        }).filter({ gckDevice in
            return gckDevice.deviceID == id
        }).first
    }

    private func startSession(_ device: GoogleCastDevice) -> Observable<GCKCastSession> {
        return Observable.create({[unowned self] observer in
            guard let gckDevice = self.device(withId: device.id) else {
                observer.onError(GoogleCastServiceError.connectionError)
                observer.onCompleted()
                return Disposables.create()
            }

            let didStartSubscription = self.sessionManager.rx.didStart.subscribe(onNext: { sessionManager in
                if let currentCastSession = sessionManager.currentCastSession {
                    observer.onNext(currentCastSession)
                } else {
                    observer.onError(GoogleCastServiceError.connectionError)
                }
                observer.onCompleted()
            })
            let didFailToStartSubscription = self.sessionManager.rx.didFailToStart.subscribe(onNext: { _ in
                observer.onError(GoogleCastServiceError.connectionError)
                observer.onCompleted()
            })

            if let castSession = self.sessionManager.currentCastSession {
                observer.onNext(castSession)
                observer.onCompleted()
            } else if !self.sessionManager.startSession(with: gckDevice) {
                observer.onError(GoogleCastServiceError.connectionError)
                observer.onCompleted()
            }
            return Disposables.create {
                didStartSubscription.dispose()
                didFailToStartSubscription.dispose()
            }
        })
    }

    private func loadMedia(_ mediaInfo: GCKMediaInformation) -> (GCKCastSession) -> Observable<Void> {
        return { castSession in
            return Observable.create({ observer in
                let request = castSession.remoteMediaClient.loadMedia(mediaInfo, autoplay: true)

                let didCompleteSubscription = request.rx.didComplete.subscribe(onNext: { _ in
                    observer.onNext()
                    observer.onCompleted()
                })
                let didFailWithErrorSubscription = request.rx.didFailWithError.subscribe(onNext: { _ in
                    observer.onError(GoogleCastServiceError.connectionError)
                    observer.onCompleted()
                })

                return Disposables.create {
                    didCompleteSubscription.dispose()
                    didFailWithErrorSubscription.dispose()
                }
            })
        }
    }

}

extension GoogleCastServiceProtocolImpl: GCKLoggerDelegate {

    func enableLogging() {
        let logFilter = GCKLoggerFilter()
        logFilter.addClassNames([
//            "GCKEventLogger",
            "\(GCKCastContext.self)",
            "\(GCKDeviceProvider.self)",
            "\(GCKDiscoveryManager.self)",
            "\(GCKSessionManager.self)",
            "\(GCKUICastButton.self)",
            "\(GCKUIMediaController.self)",
            "\(GCKUIMiniMediaControlsViewController.self)",
            "\(GCKCastChannel.self)",
            "\(GCKMediaControlChannel.self)"
            ])
        GCKLogger.sharedInstance().filter = logFilter
        GCKLogger.sharedInstance().delegate = self
    }

    func log(fromFunction function: UnsafePointer<Int8>, message: String) {
        NSLog("%s %@", function, message)
    }

}
