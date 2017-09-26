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

class FilterViewModel: FilterViewModelProtocol {

    private var filter: Filter
    private let completion: FilterViewModelCompletion
    private let disposeBag = DisposeBag()

    init(filter: Filter, completion: @escaping FilterViewModelCompletion) {
        self.filter = filter
        self.completion = completion
    }

    // MARK: SessionFilterViewModel

    let title = Driver.just(NSLocalizedString("Filter", comment: "Filter view title"))

    lazy var filterSections: Driver<[FilterSectionViewModel]> = {
        return Driver.just(self.filterViewModels)
    }()

    func didCancel() {
        self.completion(.cancelled)
    }

    func didApplyFilter() {
        self.completion(.finished(self.filter))
    }

    // MARK: Private

    private lazy var filterViewModels: [FilterSectionViewModel] = {
        return [self.yearsFilterViewModel, self.platformsFilterViewModel, self.tracksFilterViewModel]
    }()

    private lazy var yearsFilterViewModel: FilterSectionViewModel = {
        var yearFilterItems = Session.Year.all.map { year in
            return FilterItemViewModel(title: year.description, style: .checkmark, selected: self.filter.years == [year])
        }
        yearFilterItems.insert(FilterItemViewModel(title: NSLocalizedString("All years", comment: ""), style: .checkmark, selected: self.filter.years == Session.Year.all), at: 0)
        let years = SingleChoiceFilterSectionViewModel(title: NSLocalizedString("Years", comment: ""), items: yearFilterItems)
        years.selection.subscribe(onNext: { item in
            self.filter.years = self.selectedYears(at: item)
            NSLog("%@", self.filter.description)
        }).addDisposableTo(self.disposeBag)
        return years
    }()

    private lazy var platformsFilterViewModel: FilterSectionViewModel = {
        var platformFilterItems = Session.Platform.all.map { platform in
            return FilterItemViewModel(title: platform.description, style: .checkmark, selected: self.filter.platforms == [platform])
        }
        platformFilterItems.insert(FilterItemViewModel(title: NSLocalizedString("All platforms", comment: ""), style: .checkmark, selected: self.filter.platforms == Session.Platform.all), at: 0)

        let platforms = SingleChoiceFilterSectionViewModel(title: NSLocalizedString("Platforms", comment: ""), items: platformFilterItems)
        platforms.selection.subscribe(onNext: { item in
            self.filter.platforms = self.selectedPlatforms(at: item)
            NSLog("%@", self.filter.description)
        }).addDisposableTo(self.disposeBag)

        return platforms
    }()

    private lazy var tracksFilterViewModel: FilterSectionViewModel = {
        let trackFilterItems = Session.Track.all.map { track in
            return FilterItemViewModel(title: track.description, style: .switch, selected: self.filter.tracks.contains(track))
        }

        let tracks = MultiChoiceFilterSectionViewModel(title: NSLocalizedString("Tracks", comment: ""), items: trackFilterItems)
        tracks.selection.subscribe(onNext: { items in
            self.filter.tracks = self.selectedTracks(at: items)
            NSLog("%@", self.filter.description)
        }).addDisposableTo(self.disposeBag)

        return tracks
    }()

    private func selectedYears(at index: Int) -> [Session.Year] {
        if index == 0 {
            return Session.Year.all
        }
        return [Session.Year.all[index - 1]]
    }
    
    private func selectedPlatforms(at index: Int) -> Session.Platform {
        if index == 0 {
            return Session.Platform.all
        }
        return Session.Platform(rawValue: 1 << (index - 1))
    }

    private func selectedTracks(at indexes: [Int]) -> [Session.Track] {
        return indexes.map { idx in
            guard let track = Session.Track(rawValue: idx) else {
                fatalError("Failed to create a session track from \(idx) raw value!")
            }
            return track
        }
    }
}
