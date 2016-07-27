//
//  SessionDetailsPresenter.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 06/07/16.
//  Copyright © 2016 Maksym Shcheglov. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

protocol SessionDetailsPresenter: class {
    var session: Driver<SessionViewModel?> { get }
}
