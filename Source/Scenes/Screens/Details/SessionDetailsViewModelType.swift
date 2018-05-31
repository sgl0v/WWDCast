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

// INPUT
struct SessionDetailsViewModelInput {
    /// called when a screen becomes visible
    let appear: Driver<Void>
    /// called when a screen becomes hidden
    let disappear: Driver<Void>
    /// add or remove the session from favorites
    let toggleFavorite: Driver<Void>
    /// called when the user would like to choose ChromeCast device for playback
    let showDevices: Driver<Void>
    /// called when the user picked device for playback
    let startPlayback: Driver<Int>
}

// OUTPUT
struct SessionDetailsViewModelOutput {
    /// the session to present details for
    let session: Driver<SessionItemViewModel>
    /// Provides and array of available devices
    let devices: Driver<[String]>
    /// Starts the sessions playback
    let playback: Driver<Void>
    /// Emits when a signup error has occurred and a message should be displayed.
    let error: Driver<Error>
}

protocol SessionDetailsViewModelType: class {
    func transform(input: SessionDetailsViewModelInput) -> SessionDetailsViewModelOutput
}
