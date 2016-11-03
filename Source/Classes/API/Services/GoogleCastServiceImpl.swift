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

extension GCKMediaInformation {
    
    convenience init(session: Session) {
        let metadata = GCKMediaMetadata(metadataType: .generic)
        metadata.setString(session.title, forKey: kGCKMetadataKeyTitle)
        metadata.setString(session.subtitle, forKey: kGCKMetadataKeySubtitle)
        metadata.addImage(GCKImage(url: session.thumbnail as URL, width: 734, height: 413))
        let mediaTrack = GCKMediaTrack(identifier: session.id, contentIdentifier: session.captions?.absoluteString, contentType: "text/vtt", type: .text, textSubtype: .captions, name: "English Captions", languageCode: "en", customData: nil)

        self.init(contentID: session.video!.absoluteString, streamType: .none, contentType: "video/mp4", metadata: metadata, streamDuration: 0, mediaTracks: [mediaTrack], textTrackStyle: GCKMediaTextTrackStyle.createDefault(), customData: nil)
    }
}

enum GoogleCastServiceError : Error {
    case connectionError, playbackError
}

final class GoogleCastServiceImpl: NSObject, GoogleCastService {
    fileprivate let applicationID: String
    fileprivate let disposeBag = DisposeBag()
    fileprivate let deviceScanner: GCKDeviceScanner

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
    
    func play(_ session: Session, onDevice device: GoogleCastDevice) -> Observable<Void> {
        return Observable.just(device)
            .flatMap(self.connectToDevice)
            .flatMap(self.launchApplication(self.applicationID))
            .flatMap(self.playSession(session))
            .take(1)
            .do(onNext: { channel in
                self.castChannel = channel
            })
            .map({ _ in })
    }
    
    func pausePlayback() {
        guard let castChannel = self.castChannel else {
            return
        }
        castChannel.pause()
    }
    
    func resumePlayback() {
        guard let castChannel = self.castChannel else {
            return
        }
        castChannel.play()
    }
    
    // MARK: Private
    
    fileprivate var castChannel: GCKMediaControlChannel?
    fileprivate var deviceManager: GCKDeviceManager?
    
    fileprivate func connectToDevice(_ device: GoogleCastDevice) -> Observable<GCKDeviceManager> {
        return Observable.create({[unowned self] observer in
            guard let gckDevice = self.deviceScanner.devices.filter({ device.id == ($0 as! GCKDevice).deviceID }).first as? GCKDevice else {
                observer.onError(GoogleCastServiceError.connectionError)
                observer.onCompleted()
                return Disposables.create()
            }
            
            let appIdentifier = Bundle.main.infoDictionary?["CFBundleIdentifier"] as! String
            let deviceManager = GCKDeviceManager(device: gckDevice, clientPackageName: appIdentifier)
            
            deviceManager.rx.didFailToConnect.subscribe(onNext: { _ in
                observer.onError(GoogleCastServiceError.connectionError)
                observer.onCompleted()
            }).addDisposableTo(self.disposeBag)
            
            deviceManager.rx.didConnect.subscribe(onNext: { deviceManager in
                observer.onNext(deviceManager)
                observer.onCompleted()
            }).addDisposableTo(self.disposeBag)
            
            deviceManager.connect()
            
            self.deviceManager = deviceManager
            
            return Disposables.create()
        })
    }
    
    fileprivate func launchApplication(_ applicationId: String) -> (GCKDeviceManager) -> Observable<GCKDeviceManager> {
        return { deviceManager in
            return Observable.create({[unowned self] observer in
                
                deviceManager.rx.didConnectToCastApplication.subscribe(onNext: { _ in
                    observer.onNext(deviceManager)
                    observer.onCompleted()
                }).addDisposableTo(self.disposeBag)
                
                deviceManager.rx.didFailToConnectToApplication.subscribe(onNext: { error in
                    observer.onError(GoogleCastServiceError.connectionError)
                    observer.onCompleted()
                }).addDisposableTo(self.disposeBag)
                
                deviceManager.launchApplication(applicationId)
                
                return Disposables.create()
            })
        }
    }
    
    fileprivate func playSession(_ session: Session) -> (GCKDeviceManager) -> Observable<GCKMediaControlChannel> {
        return { deviceManager in
            return Observable.create({ observer in
                let mediaInfo = GCKMediaInformation(session: session)
                let mediaControlChannel = GCKMediaControlChannel()
                deviceManager.add(mediaControlChannel)
                let id = mediaControlChannel.loadMedia(mediaInfo, autoplay: true)
                if (id == kGCKInvalidRequestID) {
                    observer.onError(GoogleCastServiceError.playbackError)
                } else {
                    observer.onNext(mediaControlChannel)
                }
                observer.onCompleted()
                
                return Disposables.create {
                    deviceManager.disconnect()
                }
            })
        }
    }
    
}

extension GoogleCastServiceImpl: GCKMediaControlChannelDelegate {
    func mediaControlChannelDidUpdateStatus(_ mediaControlChannel: GCKMediaControlChannel) {
        NSLog("%@", mediaControlChannel)
    }

    func mediaControlChannelDidUpdateMetadata(_ mediaControlChannel: GCKMediaControlChannel) {
        NSLog("%@", mediaControlChannel)
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
