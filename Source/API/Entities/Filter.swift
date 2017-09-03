//
//  Filter.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 14/08/2016.
//  Copyright © 2016 Maksym Shcheglov. All rights reserved.
//

import Foundation
import RxSwift

struct Filter {
    var query = ""
    var years = Session.Year.all
    var platforms = Session.Platform.all
    var tracks = Session.Track.all
    var eventTypes = Session.EventType.all
}

extension Filter: CustomStringConvertible {
    var description: String {
        return "query='\(query)' years='\(years)' platforms='\(platforms)' tracks='\(tracks)' eventTypes='\(eventTypes)'"
    }
}

extension Filter: Hashable {
    var hashValue: Int {
        let prime = 31
        let hash = 5381
        var result = 17
        result = prime * result + self.query.hashValue
        result = prime * result + self.years.reduce(hash, { acc, year in
            return acc ^ year.hashValue
        })
        result = prime * result + self.platforms.rawValue
        result = prime * result + self.tracks.hashValue
        result = prime * result + self.eventTypes.hashValue
        return result
    }
}

func == (lhs: Filter, rhs: Filter) -> Bool {
    return lhs.query == rhs.query && lhs.years == rhs.years && lhs.platforms == rhs.platforms && lhs.tracks == rhs.tracks
        && lhs.eventTypes == rhs.eventTypes
}

extension Sequence where Iterator.Element == Session {

    func apply(_ filter: Filter) -> [Iterator.Element] {
        NSLog("filter = \(filter.eventTypes)")
        return self.filter { session in
            return (filter.query.isEmpty || session.title.lowercased().contains(filter.query.lowercased())) &&
                filter.years.contains(session.year) &&
                filter.tracks.contains(session.track) &&
                filter.eventTypes.contains(session.type) &&
                (session.platforms.isEmpty || !Set(filter.platforms).intersection(session.platforms).isEmpty)
        }
    }
}
