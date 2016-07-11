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
    func setTitle(title: String)
    var showSessions: AnyObserver<[SessionViewModel]> { get }
}
