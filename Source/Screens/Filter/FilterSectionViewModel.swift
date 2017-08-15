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

struct FilterSectionViewModel: SectionModelType, CustomStringConvertible {

    enum `Type`: String {
        case Years, Platforms, EventTypes, Tracks
    }

    let type: Type
    let items: [FilterItemViewModel]
    let selection: Observable<(Int, Bool)>

    init(type: Type, items: [FilterItemViewModel]) {
        self.type = type
        self.items = items
        self.selection = Observable.from(items.enumerated().map({ idx, item in
            return item.selected.asObservable().distinctUntilChanged().map({ (idx, $0) })
        })).merge()
    }

    func selectItem(atIndex index: Int) {
        assert(index < self.items.count)
        for (idx, item) in self.items.enumerated() {
            item.selected.value = idx == index
        }
    }

    // MARK: SectionModelType

    typealias Item = FilterItemViewModel

    init(original: FilterSectionViewModel, items: [FilterItemViewModel]) {
        self.type = original.type
        self.items = items
        self.selection = original.selection
    }

    // MARK: CustomStringConvertible
    var description: String {
        return self.type.rawValue
    }

}
