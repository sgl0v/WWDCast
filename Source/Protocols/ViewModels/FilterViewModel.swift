//
//  SessionFilterViewModel.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 28/08/2016.
//  Copyright © 2016 Maksym Shcheglov. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

enum FilterModuleResult {
    case Cancelled, Finished(Filter)
}
typealias FilterModuleCompletion = (FilterModuleResult) -> ()

protocol FilterViewModel {
    // INPUT
    func dismissObserver(cancelled: Bool) // called when the view is about to dismiss

    // OUTPUT
    // The view's title
    var title: Driver<String> { get }
    // The filter items
    var filterItems: Driver<Array<FilterSectionViewModel>> { get }
}
