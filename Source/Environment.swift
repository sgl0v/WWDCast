//
//  WWDCastAPIProtocol.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 04/07/16.
//  Copyright © 2016 Maksym Shcheglov. All rights reserved.
//

import Foundation

struct Environment {
    static var sessionsURL: URL {
        var sessionsURL = self.appleCdnURL
        sessionsURL.appendPathComponent("h8a19f8f/049CCC2F-0D8A-4F7D-BAB9-2D8F5BAA7030/contents.json")
        return sessionsURL
    }

    static var appleCdnURL: URL {
        let appleCdnURLString = "https://devimages-cdn.apple.com/wwdc-services"
        if let appleCdnURL = URL(string: appleCdnURLString) {
            return appleCdnURL
        }
        fatalError("Failed to create url from \(appleCdnURLString)")
    }

    static let googleCastAppID = "B8373B04"
}
