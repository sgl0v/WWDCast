//
//  GoogleCastService.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 09/07/16.
//  Copyright © 2016 Maksym Shcheglov. All rights reserved.
//

import Foundation
import RxSwift

enum GoogleCastServiceError : Error {
    case connectionError, playbackError
}

protocol GoogleCastService: class {

    /// The array of available devices
    var devices: [GoogleCastDevice] { get }
    
    func play(_ media: GoogleCastMedia, onDevice device: GoogleCastDevice) -> Observable<Void>
    
    /**
     Pauses playback of the current session.
     */
    func pausePlayback()
    
    /**
     Resumes playback of the current session.
     */
    func resumePlayback()
}
