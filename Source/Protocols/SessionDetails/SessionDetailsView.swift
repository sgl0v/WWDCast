//
//  SessionDetailsView.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 06/07/16.
//  Copyright © 2016 Maksym Shcheglov. All rights reserved.
//

import Foundation
import RxSwift

protocol SessionDetailsView: class {
    var showSession: Observable<Void> { get }
}
