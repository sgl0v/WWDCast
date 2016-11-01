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

class FilterViewModelImpl : FilterViewModel {
    
    fileprivate var filter: Filter
    fileprivate let completion: FilterModuleCompletion
    fileprivate let disposeBag = DisposeBag()

    init(filter: Filter, completion: @escaping FilterModuleCompletion) {
        self.filter = filter
        self.completion = completion
    }
    
    // MARK: SessionFilterViewModel
    
    let title = Driver.just(NSLocalizedString("Filter", comment: "Filter view title"))
    
    lazy var filterSections: Driver<[FilterSectionViewModel]> = {
        return Driver.just(self.filterViewModels())
    }()
    
    func dismissObserver(_ cancelled: Bool) {
        if (cancelled) {
            self.completion(.cancelled)
            return
        }
        self.completion(.finished(self.filter))
    }
    
    // MARK: Private
    
    fileprivate func filterViewModels() -> [FilterSectionViewModel] {
        let years = FilterSectionViewModel(type: .Years, items: [
            FilterItemViewModel(title: NSLocalizedString("All years", comment: ""), style: .checkmark, selected: self.filter.years == Year.allYears),
            FilterItemViewModel(title: Year._2016.description, style: .checkmark, selected: self.filter.years == [._2016]),
            FilterItemViewModel(title: Year._2015.description, style: .checkmark, selected: self.filter.years == [._2015]),
            FilterItemViewModel(title: Year._2014.description, style: .checkmark, selected: self.filter.years == [._2014]),
            FilterItemViewModel(title: Year._2013.description, style: .checkmark, selected: self.filter.years == [._2013]),
            FilterItemViewModel(title: Year._2012.description, style: .checkmark, selected: self.filter.years == [._2012]),
            ])
        let platforms = FilterSectionViewModel(type: .Platforms, items: [
            FilterItemViewModel(title: NSLocalizedString("All platforms", comment: ""), style: .checkmark, selected: self.filter.platforms == Platform.allPlatforms),
            FilterItemViewModel(title: Platform.iOS.rawValue, style: .checkmark, selected: self.filter.platforms == [.iOS]),
            FilterItemViewModel(title: Platform.macOS.rawValue, style: .checkmark, selected: self.filter.platforms == [.macOS]),
            FilterItemViewModel(title: Platform.tvOS.rawValue, style: .checkmark, selected: self.filter.platforms == [.tvOS]),
            FilterItemViewModel(title: Platform.watchOS.rawValue, style: .checkmark, selected: self.filter.platforms == [.watchOS])
            ])
        let tracks = FilterSectionViewModel(type: .Tracks, items: [
            FilterItemViewModel(title: Track.Featured.rawValue, style: .switch, selected: self.filter.tracks.contains(.Featured)),
            FilterItemViewModel(title: Track.Media.rawValue, style: .switch, selected: self.filter.tracks.contains(.Media)),
            FilterItemViewModel(title: Track.DeveloperTools.rawValue, style: .switch, selected: self.filter.tracks.contains(.DeveloperTools)),
            FilterItemViewModel(title: Track.GraphicsAndGames.rawValue, style: .switch, selected: self.filter.tracks.contains(.GraphicsAndGames)),
            FilterItemViewModel(title: Track.SystemFrameworks.rawValue, style: .switch, selected: self.filter.tracks.contains(.SystemFrameworks)),
            FilterItemViewModel(title: Track.AppFrameworks.rawValue, style: .switch, selected: self.filter.tracks.contains(.AppFrameworks)),
            FilterItemViewModel(title: Track.Design.rawValue, style: .switch, selected: self.filter.tracks.contains(.Design)),
            FilterItemViewModel(title: Track.Distribution.rawValue, style: .switch, selected: self.filter.tracks.contains(.Distribution))
            ])
        
        years.selection.filter({ _ , selected in
            return selected
        }).do(onNext: { index, _ in
            years.selectItem(atIndex: index)
        }).flatMap(self.yearsSelection(years)).distinctUntilChanged(==).subscribe(onNext: { years in
            self.filter.years = years
            NSLog("%@", self.filter.description)
        }).addDisposableTo(self.disposeBag)
        
        platforms.selection.filter({ _ , selected in
            return selected
        }).do(onNext: { index, _ in
            platforms.selectItem(atIndex: index)
        }).flatMap(self.platformsSelection(platforms)).distinctUntilChanged(==).subscribe(onNext: { platforms in
            self.filter.platforms = platforms
            NSLog("%@", self.filter.description)
        }).addDisposableTo(self.disposeBag)
        
        tracks.selection.map({ _ in
            return tracks.items.filter({item in item.selected.value }).map({ item in Track(rawValue: item.title)! })
        }).distinctUntilChanged(==).subscribe(onNext: { tracks in
            self.filter.tracks = tracks
            NSLog("%@", self.filter.description)
        }).addDisposableTo(self.disposeBag)
            
        return [years, platforms, tracks]
    }
    
    fileprivate func yearsSelection(_ platforms: FilterSectionViewModel) -> (Int, Bool) -> Observable<[Year]> {
        return { (idx, _) in
            if idx == 0 {
                return Observable.just(Year.allYears)
            }
            let selectedYear = Year.allYears[idx - 1]
            return Observable.just([selectedYear])
        }
    }
    
    fileprivate func platformsSelection(_ platforms: FilterSectionViewModel) -> (Int, Bool) -> Observable<[Platform]> {
        return { (idx, _) in
            if idx == 0 {
                return Observable.just(Platform.allPlatforms)
            }
            let selectedPlatform = Platform.allPlatforms[idx - 1]
            return Observable.just([selectedPlatform])
        }
    }
    
}
