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

struct GoogleCastDeviceImpl: GoogleCastDevice {
    var name: String
    var id: String
}

extension GCKMediaInformation {
    convenience init(session: Session) {
        let metadata = GCKMediaMetadata(metadataType: .Generic)
        metadata.setString(session.title, forKey: kGCKMetadataKeyTitle)
        metadata.setString(session.subtitle, forKey: kGCKMetadataKeySubtitle)
        metadata.setString(session.shelfImageURL.absoluteString, forKey: "castComponentPosterURL")
        metadata.addImage(GCKImage(URL: session.shelfImageURL, width: 734, height: 413))
        let mediaTrack = GCKMediaTrack(identifier: session.id, contentIdentifier: session.subtitles.absoluteString, contentType: "text/vtt", type: .Text, textSubtype: .Captions, name: "English Subtitle", languageCode: "en-US", customData: nil)

        self.init(contentID: session.sdVideoURL.absoluteString, streamType: .None, contentType: "video/mp4", metadata: metadata, streamDuration: 0, mediaTracks: [mediaTrack], textTrackStyle: GCKMediaTextTrackStyle.createDefault(), customData: nil)
    }
}

final class GoogleCastServiceImpl: NSObject, GoogleCastService {
    private var applicationID: String
    private var deviceScanner: GCKDeviceScanner
    private var deviceManager: GCKDeviceManager!
    private var mediaControlChannel: GCKMediaControlChannel!
    private var sessionQueue = [Session]()
    private let _devices = BehaviorSubject<[GoogleCastDevice]>(value: [])
    
    var devices: Observable<[GoogleCastDevice]> {return self._devices.asObservable() }

    var playSession: AnyObserver<Session> {
        return AnyObserver {[unowned self] event in
            guard case .Next(let session) = event, let device = self.deviceScanner.devices.first else {
                return
            }
            self.sessionQueue.append(session)
            self.connectToDevice(device as! GCKDevice)
        }
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
        self.enableLogging()
        self.deviceScanner.addListener(self)
        self.deviceScanner.startScan()
    }

    func connectToDevice(device: GCKDevice) {
        let appIdentifier = NSBundle.mainBundle().infoDictionary?["CFBundleIdentifier"] as? String
        self.deviceManager = GCKDeviceManager(device: device, clientPackageName: appIdentifier)
        self.deviceManager.delegate = self
        self.deviceManager.connect()
    }

}

extension GoogleCastServiceImpl: GCKDeviceManagerDelegate {

    func deviceManagerDidConnect(deviceManager: GCKDeviceManager!) {
        self.deviceManager.launchApplication(self.applicationID)
    }

    func deviceManager(deviceManager: GCKDeviceManager!, didConnectToCastApplication applicationMetadata: GCKApplicationMetadata!, sessionID: String!, launchedApplication: Bool) {
        guard let session = self.sessionQueue.last else {
            return
        }
        self.sessionQueue.removeLast()
        let mediaInfo = GCKMediaInformation(session: session)
        self.mediaControlChannel = GCKMediaControlChannel()
        self.mediaControlChannel.delegate = self
        self.deviceManager.addChannel(self.mediaControlChannel)
        let id = self.mediaControlChannel.loadMedia(mediaInfo, autoplay: true)
        print(id == kGCKInvalidRequestID)
    }

    func deviceManager(deviceManager: GCKDeviceManager!, didDisconnectWithError error: NSError!) {
        NSLog("%@", error)
    }

    func deviceManager(deviceManager: GCKDeviceManager!, didFailToConnectToApplicationWithError error: NSError!) {
        NSLog("%@", error)
    }
}

extension GoogleCastServiceImpl: GCKMediaControlChannelDelegate {
    func mediaControlChannelDidUpdateStatus(mediaControlChannel: GCKMediaControlChannel!) {
        NSLog("%@", mediaControlChannel)
    }

    func mediaControlChannelDidUpdateMetadata(mediaControlChannel: GCKMediaControlChannel!) {
        NSLog("%@", mediaControlChannel)
    }
}

extension GoogleCastServiceImpl: GCKDeviceScannerListener {

    func deviceDidComeOnline(device: GCKDevice!) {
        notify(self.deviceScanner.devices)
    }

    func deviceDidGoOffline(device: GCKDevice!) {
        notify(self.deviceScanner.devices)
    }

    private func notify(devices: [AnyObject]) {
        let devices: Array<GoogleCastDevice> = devices.map() {device in
            return GoogleCastDeviceImpl(name: device.friendlyName, id: device.deviceID)
        }
        self._devices.on(.Next(devices))
    }
}

extension GoogleCastServiceImpl: GCKLoggerDelegate {

    func enableLogging() {
        GCKLogger.sharedInstance().delegate = self
    }

    func logFromFunction(function: UnsafePointer<Int8>, message: String!) {
//        NSLog("%s %@", function, message)
    }

}
