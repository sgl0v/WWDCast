//
//  SessionsSearchPresenter.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 04/07/16.
//  Copyright © 2016 Maksym Shcheglov. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

protocol SessionsSearchPresenter: class {
    var active: Bool { get set }
    // Item selection observer
    var itemSelected: AnyObserver<SessionViewModel> { get }
    // Filter button tap observer
    var filterObserver: AnyObserver<Void> { get }
    // Search string observer
    var searchStringObserver: AnyObserver<String> { get }
    // The view's title
    var title: Driver<String> { get }
    // The array of available WWDC sessions
    var sessions: Driver<[SessionViewModels]> { get }
}
