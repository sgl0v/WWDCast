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
        return [yearsFilterViewModel(), platformsFilterViewModel(), tracksFilterViewModel()]
    }
    
    fileprivate func yearsFilterViewModel() -> FilterSectionViewModel {
        var yearFilterItems = Year.allYears.map { year in
            return FilterItemViewModel(title: year.description, style: .checkmark, selected: self.filter.years == [year])
        }
        yearFilterItems.insert(FilterItemViewModel(title: NSLocalizedString("All years", comment: ""), style: .checkmark, selected: self.filter.years == Year.allYears), at: 0)
        
        let years = FilterSectionViewModel(type: .Years, items: yearFilterItems)
        years.selection.filter({ _ , selected in
            return selected
        }).do(onNext: { index, _ in
            years.selectItem(atIndex: index)
        }).flatMap(self.yearsSelection(years)).distinctUntilChanged(==).subscribe(onNext: { years in
            self.filter.years = years
            NSLog("%@", self.filter.description)
        }).addDisposableTo(self.disposeBag)
        
        return years
    }
    
    fileprivate func platformsFilterViewModel() -> FilterSectionViewModel {
        var platformFilterItems = Platform.allPlatforms.map { platform in
            return FilterItemViewModel(title: platform.rawValue, style: .checkmark, selected: self.filter.platforms == [platform])
        }
        platformFilterItems.insert(FilterItemViewModel(title: NSLocalizedString("All platforms", comment: ""), style: .checkmark, selected: self.filter.platforms == Platform.allPlatforms), at: 0)

        
        let platforms = FilterSectionViewModel(type: .Platforms, items: platformFilterItems)
        platforms.selection.filter({ _ , selected in
            return selected
        }).do(onNext: { index, _ in
            platforms.selectItem(atIndex: index)
        }).flatMap(self.platformsSelection(platforms)).distinctUntilChanged(==).subscribe(onNext: { platforms in
            self.filter.platforms = platforms
            NSLog("%@", self.filter.description)
        }).addDisposableTo(self.disposeBag)
        
        return platforms
    }
    
    fileprivate func tracksFilterViewModel() -> FilterSectionViewModel {
        let trackFilterItems = Track.allTracks.map { track in
            return FilterItemViewModel(title: track.rawValue, style: .switch, selected: self.filter.tracks.contains(track))
        }
        
        let tracks = FilterSectionViewModel(type: .Tracks, items: trackFilterItems)
        tracks.selection.map({ _ in
            return tracks.items.filter({item in item.selected.value }).map({ item in Track(rawValue: item.title)! })
        }).distinctUntilChanged(==).subscribe(onNext: {[unowned self] tracks in
            self.filter.tracks = tracks
            NSLog("%@", self.filter.description)
        }).addDisposableTo(self.disposeBag)
        
        return tracks
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
