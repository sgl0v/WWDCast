//
//  Session.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 04/07/16.
//  Copyright © 2016 Maksym Shcheglov. All rights reserved.
//

import Foundation

enum Track: String {
    case AppFrameworks = "App Frameworks", SystemFrameworks = "System Frameworks", DeveloperTools = "Developer Tools",
        Featured = "Featured", GraphicsAndGames = "Graphics and Games", Design = "Design", Media = "Media", Distribution = "Distribution"

    static var allTracks: [Track] {
        return [.Featured, .Media, .DeveloperTools, .GraphicsAndGames, .SystemFrameworks, .AppFrameworks, .Design, .Distribution]
    }
}

enum Focus: String {
    case iOS, macOS, tvOS, watchOS
}

protocol Session {
    var uniqueId: String { get }
    var id: Int { get }
    var year: Int { get }
    var track: Track { get }
    var focus: [Focus] { get }
    var title: String { get }
    var subtitle: String { get }
    var summary: String { get }
    var videoURL: NSURL { get }
    var hdVideoURL: NSURL { get }
    var sdVideoURL: NSURL { get }
    var webpageURL: NSURL { get }
    var subtitles: NSURL { get }
    var shelfImageURL: NSURL { get }
}
