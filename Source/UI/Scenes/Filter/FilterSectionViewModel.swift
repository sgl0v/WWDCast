//
//  FilterSectionViewModel.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 27/09/2016.
//  Copyright © 2016 Maksym Shcheglov. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxDataSources

struct FilterSectionsViewModel {
    let yearsFilterViewModel: FilterSectionViewModel
    let platformsFilterViewModel: FilterSectionViewModel
    let tracksFilterViewModel: FilterSectionViewModel
    var sections: [FilterSectionViewModel] {
        return [self.yearsFilterViewModel, self.platformsFilterViewModel, self.tracksFilterViewModel]
    }
}

class FilterSectionViewModel: SectionModelType {

    let title: String
    let items: [FilterItemViewModel]

    init(title: String, items: [FilterItemViewModel]) {
        self.title = title
        self.items = items
    }

    // MARK: SectionModelType
    typealias Item = FilterItemViewModel

    required init(original: FilterSectionViewModel, items: [FilterItemViewModel]) {
        self.title = original.title
        self.items = items
    }
}
