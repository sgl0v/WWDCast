//
//  AppConfigImpl.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 04/07/16.
//  Copyright © 2016 Maksym Shcheglov. All rights reserved.
//

import Foundation

struct AppConfig {
    let sessionsURL: URL
    let videosURL: URL
    let isWWDCWeek: Bool
}

extension AppConfig: Hashable {
    var hashValue: Int {
        let prime = 31
        var result = 17
        result = prime * result + self.sessionsURL.hashValue
        result = prime * result + self.videosURL.hashValue
        result = prime * result + self.isWWDCWeek.hashValue
        return result
    }
}

func ==(lhs: AppConfig, rhs: AppConfig) -> Bool {
    return lhs.sessionsURL == rhs.sessionsURL
}
