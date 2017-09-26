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

class SingleChoiceFilterSectionViewModel: FilterSectionViewModel {

    var selection: Observable<Int> {
        return Observable.merge(self.items.enumerated().map({ idx, item in
            return item.selected.asObservable().filter({ selected in
                return selected
            }).map({ _ in
                return idx
            })
        })).distinctUntilChanged().do(onNext: self.selectItem)
    }

    private func selectItem(atIndex index: Int) {
        assert(index < self.items.count)
        let oldSelection = self.items.enumerated().filter({ (idx, item) in
            return idx != index && item.selected.value
        }).first
        oldSelection?.element.selected.value = false
    }
}

class MultiChoiceFilterSectionViewModel: FilterSectionViewModel {

    var selection: Observable<[Int]> {
        return Observable.combineLatest(self.items.map({ item in
            return item.selected.asObservable()
        })).map({ selectionMask in
            return selectionMask.enumerated().filter({ (_, selected) in
                return selected
            }).map({ (idx, _) in
                return idx
            })
        })
    }

}
