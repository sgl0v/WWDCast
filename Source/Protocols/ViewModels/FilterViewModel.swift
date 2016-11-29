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
    case cancelled, finished(Filter)
}
typealias FilterModuleCompletion = (FilterModuleResult) -> ()

protocol FilterViewModel {
    // INPUT
    // called when the user would like to close the filter screen
    func didCancel()
    // called when the user would like to apply filter and close the filter screen
    func didApplyFilter()

    // OUTPUT
    // The view's title
    var title: Driver<String> { get }
    // The filter sections
    var filterSections: Driver<[FilterSectionViewModel]> { get }
}
