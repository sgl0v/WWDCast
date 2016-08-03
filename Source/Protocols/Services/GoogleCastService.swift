//
//  GoogleCastService.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 09/07/16.
//  Copyright © 2016 Maksym Shcheglov. All rights reserved.
//

import Foundation
import RxSwift

protocol GoogleCastDevice {
    var name: String { get }
    var id: String { get }
}

protocol GoogleCastService: class {

    var devices: [GoogleCastDevice] { get }
    var playSession: AnyObserver<(GoogleCastDevice, Session)> { get }
}
