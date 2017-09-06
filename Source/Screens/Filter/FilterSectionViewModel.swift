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
        })).distinctUntilChanged().do(onNext: {[unowned self] idx in
            self.selectItem(atIndex: idx)
        })
    }

    private func selectItem(atIndex index: Int) {
        assert(index < self.items.count)
        for (idx, item) in self.items.enumerated() {
            item.selected.value = idx == index
        }
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
