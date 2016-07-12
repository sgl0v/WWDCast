//
//  SessionsSearchPresenter.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 04/07/16.
//  Copyright © 2016 Maksym Shcheglov. All rights reserved.
//

import Foundation
import RxSwift

protocol SessionsSearchPresenter: class {
    var itemSelected: AnyObserver<Int> { get }
    var updateView: AnyObserver<Void> { get }
}
