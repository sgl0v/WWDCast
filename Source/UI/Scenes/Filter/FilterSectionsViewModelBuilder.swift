//
//  FilterSectionsViewModelBuilder.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 31/01/2018.
//  Copyright © 2018 Maksym Shcheglov. All rights reserved.
//

import Foundation

final class FilterSectionsViewModelBuilder {

    static func build(from filter: Filter) -> [FilterSectionViewModel] {
        let yearsFilterViewModel = self.yearsFilterViewModel(filter)
        let platformsFilterViewModel = self.platformsFilterViewModel(filter)
        let tracksFilterViewModel = self.tracksFilterViewModel(filter)
        return [yearsFilterViewModel, platformsFilterViewModel, tracksFilterViewModel]
    }

    private static func yearsFilterViewModel(_ filter: Filter) -> FilterSectionViewModel {
        var yearFilterItems = Session.Year.all.map { year in
            return FilterItemViewModel(title: year.description, style: .checkmark, selected: filter.years == [year])
        }
        yearFilterItems.insert(FilterItemViewModel(title: NSLocalizedString("All years", comment: ""), style: .checkmark, selected: filter.years == Session.Year.all), at: 0)
        return FilterSectionViewModel(type: .year, title: NSLocalizedString("Years", comment: ""), items: yearFilterItems)
    }

    private static func platformsFilterViewModel(_ filter: Filter) -> FilterSectionViewModel {
        var platformFilterItems = Session.Platform.all.map { platform in
            return FilterItemViewModel(title: platform.description, style: .checkmark, selected: filter.platforms == [platform])
        }
        platformFilterItems.insert(FilterItemViewModel(title: NSLocalizedString("All platforms", comment: ""), style: .checkmark, selected: filter.platforms == Session.Platform.all), at: 0)

        return FilterSectionViewModel(type: .platform, title: NSLocalizedString("Platforms", comment: ""), items: platformFilterItems)
    }

    private static func tracksFilterViewModel(_ filter: Filter) -> FilterSectionViewModel {
        let trackFilterItems = Session.Track.all.map { track in
            return FilterItemViewModel(title: track.description, style: .switch, selected: filter.tracks.contains(track))
        }

        return FilterSectionViewModel(type: .tracks, title: NSLocalizedString("Tracks", comment: ""), items: trackFilterItems)
    }
}
