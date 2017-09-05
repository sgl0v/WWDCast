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

//extension Sequence where Iterator.Element : FilterItemViewModel {
//    func selectedItem() -> Iterator.Element {
//        return self.filter ({ item in
//            return item.selected.value
//        }).first!
//    }
//}

//struct SingleChoiceSectionViewModel {
//    private let selection: Observable<Int>
//    private let title: String
//    private let items: [FilterItemViewModel]
//
//    init(title: String, items: [FilterItemViewModel]) {
//        self.title = title
//        self.items = items
//        let selectedItem = items.filter({ item in
//            return item.selected.value
//        }).first!
//        let selectedIndex = items.index(of: selectedItem)!
//
//        self.selection = Observable.merge(items.enumerated().map({ idx, item in
//            return item.selected.asObservable().filter({ selected in
//                return selected
//            }).map({ _ in
//                return item
//            }).do(onNext: { _ in
//                self.selectItem(atIndex: idx)
//            })
//        })).startWith(selectedIndex)
//    }
//
//    func selectItem(atIndex index: Int) {
//        assert(index < self.items.count)
//        for (idx, item) in self.items.enumerated() {
//            item.selected.value = idx == index
//        }
//    }
//}

enum FilterSectionViewModel {
    case singleSelectionSection(title: String, items: [FilterItemViewModel])
    case multiSelectionSection(title: String, items: [FilterItemViewModel])

    var title: String {
        switch self {
        case .singleSelectionSection(let title, _):
            return title
        case .multiSelectionSection(let title, _):
            return title
        }
    }

    var singleSelection: Observable<Int> {
        return Observable.merge(items.enumerated().map({ idx, item in
            return item.selected.asObservable().filter({ selected in
                return selected
            }).map({ _ in
                return idx
            })
        })).distinctUntilChanged().do(onNext: { idx in
            self.selectItem(atIndex: idx)
        })
    }

    var multiSelection: Observable<[Int]> {
        return Observable.combineLatest(items.map({ item in
            return item.selected.asObservable()
        })).map({ selectionMask in
            return selectionMask.enumerated().filter({ (_, selected) in
                return selected
            }).map({ (idx, _) in
                return idx
            })
        })
    }

    func selectItem(atIndex index: Int) {
        assert(index < self.items.count)
        for (idx, item) in self.items.enumerated() {
            item.selected.value = idx == index
        }
    }

}

extension FilterSectionViewModel: SectionModelType {
    typealias Item = FilterItemViewModel

    var items: [FilterItemViewModel] {
        switch  self {
        case .singleSelectionSection(title: _, items: let items):
            return items
        case .multiSelectionSection(title: _, items: let items):
            return items
        }
    }

    init(original: FilterSectionViewModel, items: [FilterItemViewModel]) {
        switch original {
        case let .singleSelectionSection(title: title, items: _):
            self = .singleSelectionSection(title: title, items: items)
        case let .multiSelectionSection(title, _):
            self = .multiSelectionSection(title: title, items: items)
        }
    }
}

//struct FilterSectionViewModel: SectionModelType, CustomStringConvertible {
//
//    enum `Type`: String {
//        case Years, Platforms, EventTypes, Tracks
//    }
//
//    let type: Type
//    let items: [FilterItemViewModel]
//    let selection: Observable<(Int, Bool)>
//
//    init(type: Type, items: [FilterItemViewModel]) {
//        self.type = type
//        self.items = items
//        self.selection = Observable.from(items.enumerated().map({ idx, item in
//            return item.selected.asObservable().distinctUntilChanged().map({ (idx, $0) })
//        })).merge()
//    }
//
//    func selectItem(atIndex index: Int) {
//        assert(index < self.items.count)
//        for (idx, item) in self.items.enumerated() {
//            item.selected.value = idx == index
//        }
//    }
//
//    // MARK: SectionModelType
//
//    typealias Item = FilterItemViewModel
//
//    init(original: FilterSectionViewModel, items: [FilterItemViewModel]) {
//        self.type = original.type
//        self.items = items
//        self.selection = original.selection
//    }
//
//    // MARK: CustomStringConvertible
//    var description: String {
//        return self.type.rawValue
//    }
//
//}
