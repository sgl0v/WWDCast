//
//  SessionImpl.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 04/07/16.
//  Copyright © 2016 Maksym Shcheglov. All rights reserved.
//

import Foundation

struct Session {
    
    enum Year: UInt {
        case _2012 = 2012, _2013 = 2013, _2014 = 2014, _2015 = 2015, _2016 = 2016
        
        static let allYears: [Year] = [._2016, ._2015, ._2014, ._2013, ._2012]
    }
    
    enum Track: String {
        case AppFrameworks = "App Frameworks", SystemFrameworks = "System Frameworks", DeveloperTools = "Developer Tools",
        Featured = "Featured", GraphicsAndGames = "Graphics and Games", Design = "Design", Media = "Media", Distribution = "Distribution"
        
        static let allTracks: [Track] = [.Featured, .Media, .DeveloperTools, .GraphicsAndGames, .SystemFrameworks, .AppFrameworks, .Design, .Distribution]
    }
    
    enum Platform: String {
        case iOS, macOS, tvOS, watchOS
        
        static let allPlatforms: [Platform] = [.iOS, .macOS, .tvOS, .watchOS]
    }

    var uniqueId: String { return "#\(year)-\(id)" }
    let id: Int
    let year: Year
    let track: Track
    let platforms: [Platform]
    let title: String
    var subtitle: String {
        let focusString = self.platforms.map({ $0.rawValue }).joined(separator: ", ")
        return "\(year) - Session \(id) - \(focusString)"
    }
    let summary: String
    let video: URL?
    let captions: URL?
    let thumbnail: URL
    let favorite: Bool
}

extension Session: Hashable {

    var hashValue: Int {
        return self.uniqueId.hashValue
    }
}

func ==(lhs: Session, rhs: Session) -> Bool {
    return lhs.uniqueId == rhs.uniqueId
}

extension Session.Year: CustomStringConvertible {
    
    var description: String {
        return "WWDC \(self.rawValue)"
    }
}
