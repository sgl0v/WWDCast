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

struct FilterSectionViewModel: SectionModelType, CustomStringConvertible {

    enum Type: String {
        case Years, Platforms, Tracks
    }
    
    let type: Type
    let items: [FilterItemViewModel]
    var selection: Observable<(Int, Bool)>?
    
    init(type: Type, items: [FilterItemViewModel]) {
        self.type = type
        self.items = items
        self.selection = items.enumerate().map({ idx, item in
            return item.selected.asObservable().map({ (idx, $0) })
        }).toObservable().merge()
    }
    
    func selectItem(atIndex index: Int) {
        assert(index < self.items.count)
        for (idx, item) in self.items.enumerate() {
            let selected = idx == index
            if (item.selected.value != selected) {
                item.selected.value = selected
            }
        }
    }
    
    // MARK: SectionModelType
    
    typealias Item = FilterItemViewModel
    
    init(original: FilterSectionViewModel, items: [FilterItemViewModel]) {
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
    private let filterItemsVariable: Variable<Array<FilterSectionViewModel>>
//    var filterTrigger: Driver<NSIndexPath>?
    var filterItems: Driver<Array<FilterSectionViewModel>> {
        return self.filterItemsVariable.asDriver()
    }

    init(filter: Filter) {
        self.filter = filter
        let years = FilterSectionViewModel(type: .Years, items: [
            FilterItemViewModel(title: "All years"),
            FilterItemViewModel(title: "WWDC 2016"),
            FilterItemViewModel(title: "WWDC 2015"),
            FilterItemViewModel(title: "WWDC 2014")
            ])
        let platforms = FilterSectionViewModel(type: .Platforms, items: [
            FilterItemViewModel(title: "All Platforms", style: .Checkmark, selected: self.filter.platforms == Platform.allPlatforms),
            FilterItemViewModel(title: Platform.iOS.rawValue, style: .Checkmark, selected: self.filter.platforms == [.iOS]),
            FilterItemViewModel(title: Platform.macOS.rawValue, style: .Checkmark, selected: self.filter.platforms == [.macOS]),
            FilterItemViewModel(title: Platform.tvOS.rawValue, style: .Checkmark, selected: self.filter.platforms == [.tvOS]),
            FilterItemViewModel(title: Platform.watchOS.rawValue, style: .Checkmark, selected: self.filter.platforms == [.watchOS])
            ])
        let tracks = FilterSectionViewModel(type: .Tracks, items: [
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
        
        _ = platforms.selection?.filter({ _ , selected in
            return selected
        }).doOnNext({ index, _ in
            platforms.selectItem(atIndex: index)
        }).flatMap(self.platformsSelection(platforms)).distinctUntilChanged(==).subscribeNext({ platforms in
            self.filter.platforms = platforms
            print(self.filter)
        })
        
        _ = tracks.selection?.map({ _ in
            return tracks.items.filter({item in item.selected.value }).map({ item in Track(rawValue: item.title)! })
        }).distinctUntilChanged(==).subscribeNext({ tracks in
            self.filter.tracks = tracks
            print(self.filter)
        })
    }
    
    func platformsSelection(platforms: FilterSectionViewModel) -> (Int, Bool) -> Observable<[Platform]> {
        return { _ in
            let selectedPlatforms: [Platform]? = platforms.items.filter({ item in
                item.selected.value
            }).first.map { item in
                if let platform = Platform(rawValue: item.title) {
                    return [platform]
                }
                return Platform.allPlatforms
            }
            if let selectedPlatforms = selectedPlatforms {
                return Observable.just(selectedPlatforms)
            }
            return Observable.empty()
        }
    }

//    var itemSelected: AnyObserver<NSIndexPath> {
//        return AnyObserver {[unowned self] event in
//            guard case .Next(let indexPath) = event else {
//                return
//            }
//            
//            let filterSection = self.filterItemsVariable.value[indexPath.section]
//            if .Tracks != filterSection.type {
//                filterSection.selectItem(atIndex: indexPath.row)
//            }
//        }
//    }

}
