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
    var query: String = ""
    var years = Session.Year.allYears
    var platforms = Session.Platform.allPlatforms
    var tracks = Session.Track.allTracks
}

extension Filter: CustomStringConvertible {
    var description : String {
        return "query='\(query)' years='\(years)' platforms='\(platforms)' tracks='\(tracks)'"
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
        result = prime * result + self.platforms.reduce(hash, { acc, platform in
            return acc ^ platform.hashValue
        })
        result = prime * result + self.tracks.reduce(hash, { acc, track in
            return acc ^ track.hashValue
        })
        return result
    }
}

func ==(lhs: Filter, rhs: Filter) -> Bool {
    return lhs.query == rhs.query && lhs.years == rhs.years && lhs.platforms == rhs.platforms && lhs.tracks == rhs.tracks
}

extension Sequence where Iterator.Element == Session {
    
    func apply(_ filter: Filter) -> [Iterator.Element] {
        return self.filter { session in
            (filter.query.isEmpty || session.title.lowercased().contains(filter.query.lowercased())) &&
                filter.years.contains(session.year) &&
                filter.tracks.contains(session.track) &&
                (session.platforms.isEmpty || !Set(filter.platforms).intersection(session.platforms).isEmpty)
        }
    }
}
