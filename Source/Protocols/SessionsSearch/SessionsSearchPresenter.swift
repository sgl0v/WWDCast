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
    // Item selection observer
    var itemSelected: AnyObserver<SessionViewModel> { get }
    // Filter button tap observer
    var filter: AnyObserver<Void> { get }
    // The view's title
    var title: Driver<String> { get }
    // The array of available WWDC sessions
    var sessions: Driver<[SessionViewModels]>! { get }
}
