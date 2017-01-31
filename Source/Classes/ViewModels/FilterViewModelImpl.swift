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

class FilterViewModelImpl: FilterViewModel {

    private var filter: Filter
    private let completion: FilterModuleCompletion
    private let disposeBag = DisposeBag()

    init(filter: Filter, completion: @escaping FilterModuleCompletion) {
        self.filter = filter
        self.completion = completion
    }

    // MARK: SessionFilterViewModel

    let title = Driver.just(NSLocalizedString("Filter", comment: "Filter view title"))

    lazy var filterSections: Driver<[FilterSectionViewModel]> = {
        return Driver.just(self.filterViewModels())
    }()

    func didCancel() {
        self.completion(.cancelled)
    }

    func didApplyFilter() {
        self.completion(.finished(self.filter))
    }

    // MARK: Private

    private func filterViewModels() -> [FilterSectionViewModel] {
        return [yearsFilterViewModel(), platformsFilterViewModel(), tracksFilterViewModel()]
    }

    private func yearsFilterViewModel() -> FilterSectionViewModel {
        var yearFilterItems = Session.Year.all.map { year in
            return FilterItemViewModel(title: year.description, style: .checkmark, selected: self.filter.years == [year])
        }
        yearFilterItems.insert(FilterItemViewModel(title: NSLocalizedString("All years", comment: ""), style: .checkmark, selected: self.filter.years == Session.Year.all), at: 0)

        let years = FilterSectionViewModel(type: .Years, items: yearFilterItems)
        years.selection.filter({ _, selected in
            return selected
        }).do(onNext: { index, _ in
            years.selectItem(atIndex: index)
        }).flatMap(self.yearsSelection(years)).distinctUntilChanged(==).subscribe(onNext: { years in
            self.filter.years = years
            NSLog("%@", self.filter.description)
        }).addDisposableTo(self.disposeBag)

        return years
    }

    private func platformsFilterViewModel() -> FilterSectionViewModel {
        var platformFilterItems = Session.Platform.all.map { platform in
            return FilterItemViewModel(title: platform.rawValue, style: .checkmark, selected: self.filter.platforms == [platform])
        }
        platformFilterItems.insert(FilterItemViewModel(title: NSLocalizedString("All platforms", comment: ""), style: .checkmark, selected: self.filter.platforms == Session.Platform.all), at: 0)

        let platforms = FilterSectionViewModel(type: .Platforms, items: platformFilterItems)
        platforms.selection.filter({ _, selected in
            return selected
        }).do(onNext: { index, _ in
            platforms.selectItem(atIndex: index)
        }).flatMap(self.platformsSelection(platforms)).distinctUntilChanged(==).subscribe(onNext: { platforms in
            self.filter.platforms = platforms
            NSLog("%@", self.filter.description)
        }).addDisposableTo(self.disposeBag)

        return platforms
    }

    private func tracksFilterViewModel() -> FilterSectionViewModel {
        let trackFilterItems = Session.Track.all.map { track in
            return FilterItemViewModel(title: track.description, style: .switch, selected: self.filter.tracks.contains(track))
        }

        let tracks = FilterSectionViewModel(type: .Tracks, items: trackFilterItems)
        tracks.selection.map({ index, selected -> Session.Track in
            var tracks = self.filter.tracks
            let track = Session.Track(rawValue: 1 << index)
            if selected {
                tracks.insert(track)
            } else {
                tracks.remove(track)
            }
            return tracks
        }).distinctUntilChanged(==).subscribe(onNext: {[unowned self] tracks in
            self.filter.tracks = tracks
            NSLog("%@", self.filter.description)
        }).addDisposableTo(self.disposeBag)

        return tracks
    }

    private func yearsSelection(_ platforms: FilterSectionViewModel) -> (Int, Bool) -> Observable<[Session.Year]> {
        return { (idx, _) in
            if idx == 0 {
                return Observable.just(Session.Year.all)
            }
            let selectedYear = Session.Year.all[idx - 1]
            return Observable.just([selectedYear])
        }
    }

    private func platformsSelection(_ platforms: FilterSectionViewModel) -> (Int, Bool) -> Observable<[Session.Platform]> {
        return { (idx, _) in
            if idx == 0 {
                return Observable.just(Session.Platform.all)
            }
            let selectedPlatform = Session.Platform.all[idx - 1]
            return Observable.just([selectedPlatform])
        }
    }

}
