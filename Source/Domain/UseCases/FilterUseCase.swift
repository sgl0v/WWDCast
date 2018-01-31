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
    var value: Filter {get set}

    var filterObservable: Observable<Filter> { get }

    func save()
}
