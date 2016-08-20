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


struct FilterItemViewModel : CustomStringConvertible {
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
    let items: [FilterItemViewModel]
    var selection: Observable<(Int, Bool)>?
    
    init(type: Type, items: [FilterItemViewModel]) {
        self.type = type
        self.items = items
        if .Tracks == type {
            self.selection = items.enumerate().map({ idx, item in
                return item.selected.asObservable().map({ (idx, $0) })
            }).toObservable().merge()
        }
    }
    
    func selectItem(atIndex index: Int) {
        assert(index < self.items.count)
        for (idx, item) in self.items.enumerate() {
            item.selected.value = idx == index
        }
    }
    
    // MARK: SectionModelType
    
    typealias Item = FilterItemViewModel
    
    init(original: FilterSectionDrawable, items: [FilterItemViewModel]) {
        self.type = original.type
        self.items = items
    }
    
    // MARK: CustomStringConvertible
    var description : String {
        return self.type.rawValue
    }
    
}

class FilterViewModel {
    private var filter: Filter
    private let filterItemsVariable: Variable<Array<FilterSectionDrawable>>
//    var filterTrigger: Driver<NSIndexPath>?
    var filterItems: Driver<Array<FilterSectionDrawable>> {
        return self.filterItemsVariable.asDriver()
    }

    init(filter: Filter) {
        self.filter = filter
        let years = FilterSectionDrawable(type: .Years, items: [
            FilterItemViewModel(title: "All years"),
            FilterItemViewModel(title: "WWDC 2016"),
            FilterItemViewModel(title: "WWDC 2015"),
            FilterItemViewModel(title: "WWDC 2014")
            ])
        let platforms = FilterSectionDrawable(type: .Platforms, items: [
            FilterItemViewModel(title: "All Platforms"),
            FilterItemViewModel(title: Platform.iOS.rawValue),
            FilterItemViewModel(title: Platform.macOS.rawValue),
            FilterItemViewModel(title: Platform.tvOS.rawValue),
            FilterItemViewModel(title: Platform.watchOS.rawValue)
            ])
        let tracks = FilterSectionDrawable(type: .Tracks, items: [
            FilterItemViewModel(title: Track.Featured.rawValue, style: .Switch, selected: self.filter.tracks.contains(.Featured)),
            FilterItemViewModel(title: Track.Media.rawValue, style: .Switch, selected: self.filter.tracks.contains(.Media)),
            FilterItemViewModel(title: Track.DeveloperTools.rawValue, style: .Switch, selected: self.filter.tracks.contains(.DeveloperTools)),
            FilterItemViewModel(title: Track.GraphicsAndGames.rawValue, style: .Switch, selected: self.filter.tracks.contains(.GraphicsAndGames)),
            FilterItemViewModel(title: Track.SystemFrameworks.rawValue, style: .Switch, selected: self.filter.tracks.contains(.SystemFrameworks)),
            FilterItemViewModel(title: Track.AppFrameworks.rawValue, style: .Switch, selected: self.filter.tracks.contains(.AppFrameworks)),
            FilterItemViewModel(title: Track.Design.rawValue, style: .Switch, selected: self.filter.tracks.contains(.Design)),
            FilterItemViewModel(title: Track.Distribution.rawValue, style: .Switch, selected: self.filter.tracks.contains(.Distribution))
            ])
        
        self.filterItemsVariable = Variable([years, platforms, tracks])
        
        _ = tracks.selection?.map({ _ in
            return tracks.items.filter({item in item.selected.value }).map({ item in Track(rawValue: item.title)! })
        }).distinctUntilChanged(==).subscribeNext({ tracks in
            self.filter.tracks = tracks
            print(self.filter)
        })
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
