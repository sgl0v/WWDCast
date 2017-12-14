//
//  GoogleCastServiceProtocol.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 09/07/16.
//  Copyright © 2016 Maksym Shcheglov. All rights reserved.
//

import Foundation
import RxSwift

enum GoogleCastServiceError: Error, CustomStringConvertible {
    case connectionError, playbackError, noDevicesFound

    var description: String {
        switch self {
        case .playbackError:
            return NSLocalizedString("Failed to play media on Google Cast.", comment: "Failed to play media on Google Cast.")
        case .connectionError:
            return NSLocalizedString("Failed to connect to Google Cast.", comment: "Failed to connect to Google Cast.")
        case .noDevicesFound:
            return NSLocalizedString("Google Cast device is not found!", comment: "Google Cast devices error message.")
        }

    }
}

protocol GoogleCastServiceType: class {

    /// The array of available devices
    var devices: Observable<[GoogleCastDevice]> { get }

    /// Starts the media playback on the specified device
    func play(media: GoogleCastMedia, onDevice device: GoogleCastDevice) -> Observable<Void>

    /// Pauses playback of the current session.
    func pausePlayback()

    /// Resumes playback of the current session.
    func resumePlayback()
}
