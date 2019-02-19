//
//  Environment.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 04/07/16.
//  Copyright © 2016 Maksym Shcheglov. All rights reserved.
//

import Foundation

struct Environment {
    static var sessionsURL: URL {
        var sessionsURL = self.appleCdnURL
        sessionsURL.appendPathComponent("j06970e2/296E57DA-8CE8-4526-9A3E-F0D0E8BD6543/contents.json")
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
