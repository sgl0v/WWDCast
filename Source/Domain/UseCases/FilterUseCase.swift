//
//  FilterUseCaseType.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 02/01/2018.
//  Copyright © 2018 Maksym Shcheglov. All rights reserved.
//

import Foundation
import RxSwift

protocol FilterUseCaseType {
    /// The session search filter
    var filter: Observable<Filter> { get }

    func filter(with years: [Session.Year])
    func filter(with platforms: Session.Platform)
    func filter(with tracks: [Session.Track])
}
