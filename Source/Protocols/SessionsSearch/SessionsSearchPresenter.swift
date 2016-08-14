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
    var itemSelected: AnyObserver<SessionViewModel> { get }
    var updateView: AnyObserver<String> { get }
    var sessions: Driver<[SessionViewModels]>! { get }
}
