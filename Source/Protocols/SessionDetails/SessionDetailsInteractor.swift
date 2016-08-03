//
//  SessionDetailsInteractor.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 06/07/16.
//  Copyright © 2016 Maksym Shcheglov. All rights reserved.
//

import Foundation
import RxSwift

protocol SessionDetailsInteractor: class {

    var session: Observable<Session> { get }
    var playSession: AnyObserver<(GoogleCastDevice, Session)> { get }
    var devices: [GoogleCastDevice] { get }
}
