//
//  FilterViewModel.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 14/08/2016.
//  Copyright © 2016 Maksym Shcheglov. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxDataSources

struct FilterDrawable: CustomStringConvertible {
    let title: String
    let selected: Variable<Bool>
    
    init(title: String, selected: Variable<Bool> = Variable(false)) {
        self.title = title
        self.selected = selected
    }
    
    // MARK: CustomStringConvertible
    var description : String {
        return self.title
    }
}

struct FilterSectionDrawable: SectionModelType, CustomStringConvertible {
    
    let title: String
    let items: [FilterDrawable]
    
    init(title: String, items: [FilterDrawable]) {
        self.title = title
        self.items = items
    }
    
    func selectItem(atIndex index: Int) {
        assert(index < self.items.count)
        for (idx, item) in self.items.enumerate() {
            item.selected.value = idx == index
        }
    }
    
    // MARK: SectionModelType
    
    typealias Item = FilterDrawable
    
    init(original: FilterSectionDrawable, items: [FilterDrawable]) {
        self.title = original.title
        self.items = items
    }
    
    // MARK: CustomStringConvertible
    var description : String {
        return self.title
    }
    
}

class FilterViewModel {
    private var filter: Variable<Filter>
    private let filterItemsVariable: Variable<Array<FilterSectionDrawable>>
//    var filterTrigger: Driver<NSIndexPath>?
    var filterItems: Driver<Array<FilterSectionDrawable>> {
        return self.filterItemsVariable.asDriver()
    }

    init() {
        self.filter = Variable(Filter())
        let years = FilterSectionDrawable(title: "Years", items: [FilterDrawable(title: "All years"), FilterDrawable(title: "WWDC 2016"), FilterDrawable(title: "WWDC 2015"), FilterDrawable(title: "WWDC 2014")])
        let platforms = FilterSectionDrawable(title: "Platforms", items: [FilterDrawable(title: "All Platforms"), FilterDrawable(title: "iOS"), FilterDrawable(title: "macOS"), FilterDrawable(title: "tvOS"), FilterDrawable(title: "watchOS")])
        let tracks = FilterSectionDrawable(title: "Tracks", items: [FilterDrawable(title: "Featured"), FilterDrawable(title: "Media"), FilterDrawable(title: "Developer Tools"), FilterDrawable(title: "Graphics and Games"), FilterDrawable(title: "System Frameworks"), FilterDrawable(title: "App Frameworks"), FilterDrawable(title: "Design"), FilterDrawable(title: "Distribution")])
        
        self.filterItemsVariable = Variable([years, platforms, tracks])
    }

    var itemSelected: AnyObserver<NSIndexPath> {
        return AnyObserver {[unowned self] event in
            guard case .Next(let indexPath) = event else {
                return
            }
            
            let filterSection = self.filterItemsVariable.value[indexPath.section]
            filterSection.selectItem(atIndex: indexPath.row)
        }
    }

}
