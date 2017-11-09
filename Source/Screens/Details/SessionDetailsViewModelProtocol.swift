//
//  SessionDetailsViewModel.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 06/07/16.
//  Copyright © 2016 Maksym Shcheglov. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

protocol SessionDetailsViewModelProtocol: class {
    // INPUT

    /// add or remove the session from favorites
    func toggleFavorite()

    /// called when the user picked debice for playback
    func startPlaybackOnDevice(at index: Int)

    // OUTPUT

    /// the session to present details for
    var session: Driver<SessionItemViewModel?> { get }

    /// Provides and array of available devices
    var devices: Driver<[String]> { get }

    /// Emits when a signup error has occurred and a message should be displayed.
    var error: Driver<(String?, String)> { get }
}
