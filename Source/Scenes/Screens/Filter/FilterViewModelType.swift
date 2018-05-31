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

struct FilterViewModelInput {
    /// triggers a screen's content loading
    let loading: Driver<Void>
    /// called when the user taps on a filter item
    let selection: Driver<IndexPath>
    /// called when the user would like to close the filter screen
    let cancel: Driver<Void>
    /// called when the user would like to apply filter and close the filter screen
    let apply: Driver<Void>
}

struct FilterViewModelOutput {
    /// The filter sections
    let filterSections: Driver<[FilterSectionViewModel]>
}

protocol FilterNavigator: class {
    /// Presents the filter screen
    func dismiss()
}

/// A `FilterViewModelType` defines viewModel for the filter screen.
protocol FilterViewModelType: class {
    /// Trandforms input state to the output state
    ///
    /// - Parameter input: input state
    /// - Returns: output state
    func transform(input: FilterViewModelInput) -> FilterViewModelOutput
}
