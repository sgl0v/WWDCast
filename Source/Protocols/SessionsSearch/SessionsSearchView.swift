//
//  SessionsSearchView.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 04/07/16.
//  Copyright © 2016 Maksym Shcheglov. All rights reserved.
//

import Foundation
import RxSwift

protocol SessionsSearchView: class {
    var titleText: AnyObserver<String> { get }
//    var showSessions: AnyObserver<[SessionViewModels]> { get }
    var searchQuery: Observable<String> { get }
}
