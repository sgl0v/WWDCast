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

    private let useCase: FilterUseCaseType
    private let navigator: FilterNavigator
    private let disposeBag = DisposeBag()

    init(useCase: FilterUseCaseType, navigator: FilterNavigator) {
        self.useCase = useCase
        self.navigator = navigator
    }

    // MARK: SessionFilterViewModel

    func transform(input: FilterViewModelInput) -> FilterViewModelOutput {
        let filterSections = input.loading.withLatestFrom(self.useCase.filter.asDriverOnErrorJustComplete()).map(self.filterViewModels)
        input.cancel.drive(onNext: self.navigator.dismiss).addDisposableTo(self.disposeBag)
        input.apply.drive(onNext: self.navigator.dismiss).addDisposableTo(self.disposeBag)

        return FilterViewModelOutput(filterSections: filterSections)
    }

    // MARK: Private

    private func filterViewModels(_ filter: Filter) -> [FilterSectionViewModel] {
        return [self.yearsFilterViewModel(filter), self.platformsFilterViewModel(filter), self.tracksFilterViewModel(filter)]
    }

    private func yearsFilterViewModel(_ filter: Filter) -> FilterSectionViewModel {
        var yearFilterItems = Session.Year.all.map { year in
            return FilterItemViewModel(title: year.description, style: .checkmark, selected: filter.years == [year])
        }
        yearFilterItems.insert(FilterItemViewModel(title: NSLocalizedString("All years", comment: ""), style: .checkmark, selected: filter.years == Session.Year.all), at: 0)
        let years = SingleChoiceFilterSectionViewModel(title: NSLocalizedString("Years", comment: ""), items: yearFilterItems)
        years.selection.subscribe(onNext: {[unowned self] item in
            self.useCase.filter(with: self.selectedYears(at: item))
        }).addDisposableTo(self.disposeBag)
        return years
    }

    private func platformsFilterViewModel(_ filter: Filter) -> FilterSectionViewModel {
        var platformFilterItems = Session.Platform.all.map { platform in
            return FilterItemViewModel(title: platform.description, style: .checkmark, selected: filter.platforms == [platform])
        }
        platformFilterItems.insert(FilterItemViewModel(title: NSLocalizedString("All platforms", comment: ""), style: .checkmark, selected: filter.platforms == Session.Platform.all), at: 0)

        let platforms = SingleChoiceFilterSectionViewModel(title: NSLocalizedString("Platforms", comment: ""), items: platformFilterItems)
        platforms.selection.subscribe(onNext: {[unowned self] item in
            self.useCase.filter(with: self.selectedPlatforms(at: item))
        }).addDisposableTo(self.disposeBag)

        return platforms
    }

    private func tracksFilterViewModel(_ filter: Filter) -> FilterSectionViewModel {
        let trackFilterItems = Session.Track.all.map { track in
            return FilterItemViewModel(title: track.description, style: .switch, selected: filter.tracks.contains(track))
        }

        let tracks = MultiChoiceFilterSectionViewModel(title: NSLocalizedString("Tracks", comment: ""), items: trackFilterItems)
        tracks.selection.subscribe(onNext: {[unowned self] items in
            self.useCase.filter(with: self.selectedTracks(at: items))
        }).addDisposableTo(self.disposeBag)

        return tracks
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

    private func selectedTracks(at indexes: [Int]) -> [Session.Track] {
        return indexes.map { idx in
            guard let track = Session.Track(rawValue: idx) else {
                fatalError("Failed to create a session track from \(idx) raw value!")
            }
            return track
        }
    }
}
