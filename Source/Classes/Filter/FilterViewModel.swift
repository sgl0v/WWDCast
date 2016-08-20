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
    
    enum Style {
        case Checkmark, Switch
    }

    let title: String
    let selected: Variable<Bool>
    let style: Style
    
    init(title: String, style: Style = .Checkmark, selected: Bool = false) {
        self.title = title
        self.style = style
        self.selected = Variable(selected)
    }
    
    // MARK: CustomStringConvertible
    var description : String {
        return self.title
    }
}

struct FilterSectionDrawable: SectionModelType, CustomStringConvertible {

    enum Type: String {
        case Years, Platforms, Tracks
    }
    
    let type: Type
    let items: [FilterDrawable]
    
    init(type: Type, items: [FilterDrawable]) {
        self.type = type
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
        self.type = original.type
        self.items = items
    }
    
    // MARK: CustomStringConvertible
    var description : String {
        return self.type.rawValue
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
        let years = FilterSectionDrawable(type: .Years, items: [FilterDrawable(title: "All years"), FilterDrawable(title: "WWDC 2016"), FilterDrawable(title: "WWDC 2015"), FilterDrawable(title: "WWDC 2014")])
        let platforms = FilterSectionDrawable(type: .Platforms, items: [FilterDrawable(title: "All Platforms"), FilterDrawable(title: "iOS"), FilterDrawable(title: "macOS"), FilterDrawable(title: "tvOS"), FilterDrawable(title: "watchOS")])
        let tracks = FilterSectionDrawable(type: .Tracks, items: [FilterDrawable(title: "Featured", style: .Switch, selected: true), FilterDrawable(title: "Media", style: .Switch, selected: true), FilterDrawable(title: "Developer Tools", style: .Switch, selected: true), FilterDrawable(title: "Graphics and Games", style: .Switch, selected: true), FilterDrawable(title: "System Frameworks", style: .Switch, selected: true), FilterDrawable(title: "App Frameworks", style: .Switch, selected: true), FilterDrawable(title: "Design", style: .Switch, selected: true), FilterDrawable(title: "Distribution", style: .Switch, selected: true)])
        
        self.filterItemsVariable = Variable([years, platforms, tracks])
    }

    var itemSelected: AnyObserver<NSIndexPath> {
        return AnyObserver {[unowned self] event in
            guard case .Next(let indexPath) = event else {
                return
            }
            
            let filterSection = self.filterItemsVariable.value[indexPath.section]
            if .Tracks != filterSection.type {
                filterSection.selectItem(atIndex: indexPath.row)
            }
        }
    }

}
