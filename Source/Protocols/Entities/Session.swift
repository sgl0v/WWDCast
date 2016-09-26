//
//  Session.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 04/07/16.
//  Copyright © 2016 Maksym Shcheglov. All rights reserved.
//

import Foundation

enum Year: UInt {
    case _2012 = 2012, _2013 = 2013, _2014 = 2014, _2015 = 2015, _2016 = 2016
    
    static var allYears: [Year] {
        return [._2016, ._2015, ._2014, ._2013, ._2012]
    }

}

extension Year: CustomStringConvertible {

    var description: String {
        return "WWDC \(self.rawValue)"
    }
}

enum Track: String {
    case AppFrameworks = "App Frameworks", SystemFrameworks = "System Frameworks", DeveloperTools = "Developer Tools",
        Featured = "Featured", GraphicsAndGames = "Graphics and Games", Design = "Design", Media = "Media", Distribution = "Distribution"

    static var allTracks: [Track] {
        return [.Featured, .Media, .DeveloperTools, .GraphicsAndGames, .SystemFrameworks, .AppFrameworks, .Design, .Distribution]
    }
}

enum Platform: String {
    case iOS, macOS, tvOS, watchOS
    
    static var allPlatforms: [Platform] {
        return [.iOS, .macOS, .tvOS, .watchOS]
    }
}

protocol Session {
    var uniqueId: String { get }
    var id: Int { get }
    var year: Year { get }
    var track: Track { get }
    var platforms: [Platform] { get }
    var title: String { get }
    var subtitle: String { get }
    var summary: String { get }
    var videoURL: NSURL { get }
    var subtitles: NSURL { get }
    var shelfImageURL: NSURL { get }
}

extension SequenceType where Generator.Element == Session {
    
    func apply(filter: Filter) -> [Generator.Element] {
        return self.filter { session in
            (filter.query.isEmpty || session.title.lowercaseString.containsString(filter.query.lowercaseString)) &&
                filter.years.contains(session.year) &&
                filter.tracks.contains(session.track) &&
                !Set(filter.platforms).intersect(session.platforms).isEmpty
        }
    }
}
