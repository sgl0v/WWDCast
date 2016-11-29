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

protocol SessionDetailsViewModel: class {
    // INPUT
    func didTapPlaySession() // start the current session payback
    func didToggleFavorite() // add or remove the session from favorites

    // OUTPUT
    var title: Driver<String> { get } // The view's title
    var session: Driver<SessionItemViewModel?> { get } // the session to present details for
}
