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
        let initialSections = initialFilter.map(FilterSectionsViewModelBuilder.build)
        let currentFilter = input.selection.map({ indexPath in
            self.filter(from: self.useCase.value, with: indexPath)
        }).do(onNext: { filter in
            self.useCase.value = filter
        })
        let filterSections = currentFilter.map(FilterSectionsViewModelBuilder.build)
        let sections = Driver.merge(initialSections, filterSections)
        input.cancel.drive(onNext: self.navigator.dismiss).addDisposableTo(self.disposeBag)
        input.apply.drive(onNext: {[unowned self] in
            self.useCase.save()
            self.navigator.dismiss()
        }).addDisposableTo(self.disposeBag)

        return FilterViewModelOutput(filterSections: sections)
    }

    // MARK: Private

    private func filter(from filter: Filter, with selection: IndexPath) -> Filter {
        var selectedYears = filter.years
        var selectedPlatforms = filter.platforms
        var selectedTracks = filter.tracks

        let idx = selection.row
        guard let sectionType = FilterSectionType(rawValue: selection.section) else {
            assertionFailure("The filter type is not supported!")
            return filter
        }
        switch sectionType {
        case .year:
            selectedYears = self.selectedYears(at: idx)
        case .platform:
            selectedPlatforms = self.selectedPlatforms(at: idx)
        case .tracks:
            let selectedTrack = self.selectedTrack(at: idx)
            if let index = selectedTracks.index(of: selectedTrack) {
                selectedTracks.remove(at: index)
            } else {
                selectedTracks.append(selectedTrack)
            }
        }
        return Filter(query: filter.query, years: selectedYears, platforms: selectedPlatforms, tracks: selectedTracks)
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
        guard let track = Session.Track(rawValue: index) else {
            fatalError("Failed to create a session track from \(index) raw value!")
        }
        return track
    }
}
