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

enum FilterSectionType: Int {
    case year, platform, tracks
}

struct FilterSectionViewModel: SectionModelType {

    let type: FilterSectionType
    let title: String
    let items: [FilterItemViewModel]

    init(type: FilterSectionType, title: String, items: [FilterItemViewModel]) {
        self.type = type
        self.title = title
        self.items = items
    }

    // MARK: SectionModelType
    typealias Item = FilterItemViewModel

    init(original: FilterSectionViewModel, items: [FilterItemViewModel]) {
        self.type = original.type
        self.title = original.title
        self.items = items
    }
}
