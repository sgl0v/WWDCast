//
//  GoogleCastServiceImpl.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 09/07/16.
//  Copyright © 2016 Maksym Shcheglov. All rights reserved.
//

import Foundation
import GoogleCast
import RxSwift
import RxCocoa

final class GoogleCastServiceImpl: NSObject, GoogleCastService {
    private let applicationID: String
    private let disposeBag = DisposeBag()
    private let deviceScanner: GCKDeviceScanner
    private var currentSession: GCKCastSession? {
        return self.sessionManager.currentCastSession
    }
    private var sessionManager: GCKSessionManager {
        return GCKCastContext.sharedInstance().sessionManager
    }

    init(applicationID: String) {
        self.applicationID = applicationID
        // Create filter criteria to only show devices that can run your app
        let filterCriteria = GCKFilterCriteria(forAvailableApplicationWithID: applicationID)
        // Add the criteria to the scanner to only show devices that can run your app.
        // This allows you to publish your app to the Apple App store before before publishing in Cast
        // console. Once the app is published in Cast console the cast icon will begin showing up on ios
        // devices. If an app is not published in the Cast console the cast icon will only appear for
        // whitelisted dongles
        self.deviceScanner = GCKDeviceScanner(filterCriteria: filterCriteria)
        super.init()
        let options = GCKCastOptions(receiverApplicationID: self.applicationID)
        GCKCastContext.setSharedInstanceWith(options)
        
        self.enableLogging()
        self.deviceScanner.add(self)
        self.deviceScanner.startScan()
    }
    
    // MARK: GoogleCastService
    
    var devices: [GoogleCastDevice] {
        return self.deviceScanner.devices.map() {device in
            return GoogleCastDevice(name: (device as AnyObject).friendlyName, id: (device as AnyObject).deviceID)
        }
    }
    
    func play(_ media: GoogleCastMedia, onDevice device: GoogleCastDevice) -> Observable<Void> {
        return Observable.just(device)
            .flatMap(self.connectToDevice)
            .flatMap(self.play(media.gckMedia))
    }
    
    func pausePlayback() {
//        guard let castChannel = self.castChannel else {
//            return
//        }
//        castChannel.pause()
    }
    
    func resumePlayback() {
//        guard let castChannel = self.castChannel else {
//            return
//        }
//        castChannel.play()
    }
    
    // MARK: Private
    
    private func connectToDevice(_ device: GoogleCastDevice) -> Observable<GCKCastSession> {
        return Observable.create({[unowned self] observer in
            guard let gckDevice = self.deviceScanner.devices.filter({ device.id == ($0 as! GCKDevice).deviceID }).first as? GCKDevice else {
                observer.onError(GoogleCastServiceError.connectionError)
                observer.onCompleted()
                return Disposables.create()
            }
            
            self.sessionManager.rx.didStart.subscribe(onNext: { sessionManager in
                observer.onNext(sessionManager.currentCastSession!)
                observer.onCompleted()
            }).addDisposableTo(self.disposeBag)
            self.sessionManager.rx.didFailToStart.subscribe(onNext: { error in
                observer.onError(GoogleCastServiceError.connectionError)
                observer.onCompleted()
            }).addDisposableTo(self.disposeBag)

            if let castSession = self.sessionManager.currentCastSession {
                observer.onNext(castSession)
                observer.onCompleted()
            } else if !self.sessionManager.startSession(with: gckDevice) {
                observer.onError(GoogleCastServiceError.connectionError)
                observer.onCompleted()
            }
            return Disposables.create()
        })
    }
    
    private func play(_ mediaInfo: GCKMediaInformation) -> (GCKCastSession) -> Observable<Void> {
        return { castSession in
            return Observable.create({ observer in
                let request = castSession.remoteMediaClient.loadMedia(mediaInfo, autoplay: true)
                request.rx.didComplete.subscribe(onNext: { sessionManager in
                    observer.onNext()
                    observer.onCompleted()
                }).addDisposableTo(self.disposeBag)
                request.rx.didFailWithError.subscribe(onNext: { error in
                    observer.onError(GoogleCastServiceError.connectionError)
                    observer.onCompleted()
                }).addDisposableTo(self.disposeBag)
                
                return Disposables.create()
            })
        }
    }
    
}

extension GoogleCastServiceImpl: GCKDeviceScannerListener {

    func deviceDidComeOnline(_ device: GCKDevice) {

    }

    func deviceDidGoOffline(_ device: GCKDevice) {

    }

    func deviceDidChange(_ device: GCKDevice) {

    }
}

extension GoogleCastServiceImpl: GCKLoggerDelegate {

    func enableLogging() {
        GCKLogger.sharedInstance().delegate = self
    }

    func log(fromFunction function: UnsafePointer<Int8>, message: String) {
        NSLog("%s %@", function, message)
    }

}
