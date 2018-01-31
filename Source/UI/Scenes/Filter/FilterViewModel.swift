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

class FilterViewModel: FilterViewModelType {

    private var useCase: FilterUseCaseType
    private let navigator: FilterNavigator
    private let disposeBag = DisposeBag()

    init(useCase: FilterUseCaseType, navigator: FilterNavigator) {
        self.useCase = useCase
        self.navigator = navigator
    }

    // MARK: SessionFilterViewModel

    func transform(input: FilterViewModelInput) -> FilterViewModelOutput {
        let initialFilter = input.loading.withLatestFrom(self.useCase.filterObservable.asDriverOnErrorJustComplete())
        let initialSections = initialFilter.map(self.filterSectionsViewModel)
        let currentFilter = input.selection.map({ indexPath in
            self.filter(from: self.useCase.value, with: indexPath)
        }).do(onNext: { filter in
            self.useCase.value = filter
        })
        let filterSections = currentFilter.map(self.filterSectionsViewModel)
        let sections = Driver.merge(initialSections, filterSections)
        input.cancel.drive(onNext: self.navigator.dismiss).addDisposableTo(self.disposeBag)
        input.apply.drive(onNext: {[unowned self] in
            self.useCase.save()
            self.navigator.dismiss()
        }).addDisposableTo(self.disposeBag)

        return FilterViewModelOutput(filterSections: sections)
    }

    // MARK: Private

    private func filterSectionsViewModel(from filter: Filter) -> FilterSectionsViewModel {
        let yearsFilterViewModel = self.yearsFilterViewModel(filter)
        let platformsFilterViewModel = self.platformsFilterViewModel(filter)
        let tracksFilterViewModel = self.tracksFilterViewModel(filter)
        return FilterSectionsViewModel(yearsFilterViewModel: yearsFilterViewModel, platformsFilterViewModel: platformsFilterViewModel,
                                       tracksFilterViewModel: tracksFilterViewModel)
    }

    private func filter(from filter: Filter, with selection: IndexPath) -> Filter {
        var selectedYears = filter.years
        var selectedPlatforms = filter.platforms
        var selectedTracks = filter.tracks

        switch (selection.section, selection.row) {
        case (0, let idx):
            selectedYears = self.selectedYears(at: idx)
        case (1, let idx):
            selectedPlatforms = self.selectedPlatforms(at: idx)
        case (2, let idx):
            let selectedTrack = self.selectedTrack(at: idx)
            selectedTracks = selectedTracks.contains(selectedTrack) ? selectedTracks.remove(at: selectedTracks.index(of: selectedTrack)!) : selectedTracks.append(selectedTrack)
        default:
            assertionFailure("The filter type is not supported!")
        }
        return Filter(query: "", years: selectedYears, platforms: selectedPlatforms, tracks: selectedTracks)
    }

    private func yearsFilterViewModel(_ filter: Filter) -> FilterSectionViewModel {
        var yearFilterItems = Session.Year.all.map { year in
            return FilterItemViewModel(title: year.description, style: .checkmark, selected: filter.years == [year])
        }
        yearFilterItems.insert(FilterItemViewModel(title: NSLocalizedString("All years", comment: ""), style: .checkmark, selected: filter.years == Session.Year.all), at: 0)
        return FilterSectionViewModel(title: NSLocalizedString("Years", comment: ""), items: yearFilterItems)
    }

    private func platformsFilterViewModel(_ filter: Filter) -> FilterSectionViewModel {
        var platformFilterItems = Session.Platform.all.map { platform in
            return FilterItemViewModel(title: platform.description, style: .checkmark, selected: filter.platforms == [platform])
        }
        platformFilterItems.insert(FilterItemViewModel(title: NSLocalizedString("All platforms", comment: ""), style: .checkmark, selected: filter.platforms == Session.Platform.all), at: 0)

        return FilterSectionViewModel(title: NSLocalizedString("Platforms", comment: ""), items: platformFilterItems)
    }

    private func tracksFilterViewModel(_ filter: Filter) -> FilterSectionViewModel {
        let trackFilterItems = Session.Track.all.map { track in
            return FilterItemViewModel(title: track.description, style: .switch, selected: filter.tracks.contains(track))
        }

        return FilterSectionViewModel(title: NSLocalizedString("Tracks", comment: ""), items: trackFilterItems)
    }

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

    private func selectedTrack(at index: Int) -> Session.Track {
        guard let track = Session.Track(rawValue: idx) else {
            fatalError("Failed to create a session track from \(idx) raw value!")
        }
        return track
    }
}
