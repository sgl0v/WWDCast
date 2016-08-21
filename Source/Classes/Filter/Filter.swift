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
    var year = Set<Int>()
    var platforms = Platform.allPlatforms
    var tracks = Track.allTracks
}

extension Filter: CustomStringConvertible {
    var description : String {
        return "query='\(query)' year='\(year)' platforms='\(platforms)' tracks='\(tracks)'"
    }
}

//extension Filter: Hashable {
//    var hashValue: Int {
//        let prime = 31
//        var result = 17
//        result = prime * result + self.query.hashValue
//        result = prime * result + self.year.hashValue
//        result = prime * result + self.platforms.hashValue
//        result = prime * result + self.tracks.hashValue
//        return result
//    }
//}
//
//func ==(lhs: Filter, rhs: Filter) -> Bool {
//    return lhs.query == rhs.query && lhs.year == rhs.year && lhs.platforms == rhs.platforms && lhs.tracks == rhs.tracks
//}
