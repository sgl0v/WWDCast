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
    let selection: Observable<(Int, Bool)>
    
    init(type: Type, items: [FilterItemViewModel]) {
        self.type = type
        self.items = items
        self.selection = items.enumerate().map({ idx, item in
            return item.selected.asObservable().distinctUntilChanged().map({ (idx, $0) })
        }).toObservable().merge()
    }
    
    func selectItem(atIndex index: Int) {
        assert(index < self.items.count)
        for (idx, item) in self.items.enumerate() {
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
    var description : String {
        return self.type.rawValue
    }
    
}

class FilterViewModelImpl : FilterViewModel {
    
    private var filter: Filter
    private let completion: FilterModuleCompletion
    private let disposeBag = DisposeBag()

    init(filter: Filter, completion: FilterModuleCompletion) {
        self.filter = filter
        self.completion = completion
    }
    
    // MARK: SessionFilterViewModel
    
    let title = Driver.just(NSLocalizedString("Filter", comment: "Filter view title"))
    
    lazy var filterItems: Driver<Array<FilterSectionViewModel>> = {
        return Driver.just(self.filterViewModels())
    }()
    
    func dismissObserver(cancelled: Bool) {
        if (cancelled) {
            self.completion(.Cancelled)
            return
        }
        self.completion(.Finished(self.filter))
    }
    
    // MARK: Private
    
    private func filterViewModels() -> [FilterSectionViewModel] {
        let years = FilterSectionViewModel(type: .Years, items: [
            FilterItemViewModel(title: NSLocalizedString("All years", comment: ""), style: .Checkmark, selected: self.filter.years == Year.allYears),
            FilterItemViewModel(title: Year._2016.description, style: .Checkmark, selected: self.filter.years == [._2016]),
            FilterItemViewModel(title: Year._2015.description, style: .Checkmark, selected: self.filter.years == [._2015]),
            FilterItemViewModel(title: Year._2014.description, style: .Checkmark, selected: self.filter.years == [._2014]),
            FilterItemViewModel(title: Year._2013.description, style: .Checkmark, selected: self.filter.years == [._2013]),
            FilterItemViewModel(title: Year._2012.description, style: .Checkmark, selected: self.filter.years == [._2012]),
            ])
        let platforms = FilterSectionViewModel(type: .Platforms, items: [
            FilterItemViewModel(title: NSLocalizedString("All platforms", comment: ""), style: .Checkmark, selected: self.filter.platforms == Platform.allPlatforms),
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
        
        years.selection.filter({ _ , selected in
            return selected
        }).doOnNext({ index, _ in
            years.selectItem(atIndex: index)
        }).flatMap(self.yearsSelection(years)).distinctUntilChanged(==).subscribeNext({ years in
            self.filter.years = years
            print(self.filter)
        }).addDisposableTo(self.disposeBag)
        
        platforms.selection.filter({ _ , selected in
            return selected
        }).doOnNext({ index, _ in
            platforms.selectItem(atIndex: index)
        }).flatMap(self.platformsSelection(platforms)).distinctUntilChanged(==).subscribeNext({ platforms in
            self.filter.platforms = platforms
            print(self.filter)
        }).addDisposableTo(self.disposeBag)
        
        tracks.selection.map({ _ in
            return tracks.items.filter({item in item.selected.value }).map({ item in Track(rawValue: item.title)! })
        }).distinctUntilChanged(==).subscribeNext({ tracks in
            self.filter.tracks = tracks
            print(self.filter)
        }).addDisposableTo(self.disposeBag)
            
        return [years, platforms, tracks]
    }
    
    private func yearsSelection(platforms: FilterSectionViewModel) -> (Int, Bool) -> Observable<[Year]> {
        return { (idx, _) in
            if idx == 0 {
                return Observable.just(Year.allYears)
            }
            let selectedYear = Year.allYears[idx - 1]
            return Observable.just([selectedYear])
        }
    }
    
    private func platformsSelection(platforms: FilterSectionViewModel) -> (Int, Bool) -> Observable<[Platform]> {
        return { (idx, _) in
            if idx == 0 {
                return Observable.just(Platform.allPlatforms)
            }
            let selectedPlatform = Platform.allPlatforms[idx - 1]
            return Observable.just([selectedPlatform])
        }
    }
    
}
