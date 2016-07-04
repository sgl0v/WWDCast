//
//  AppConfigImpl.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 04/07/16.
//  Copyright © 2016 Maksym Shcheglov. All rights reserved.
//

import Foundation

struct AppConfigImpl: AppConfig {
    var sessionsURL: String = ""
    var videosURL: String = ""
    var isWWDCWeek: Bool = false
}

extension AppConfigImpl: Hashable {
    var hashValue: Int {
        let prime = 31
        var result = 17
        result = prime * result + self.sessionsURL.hashValue
        result = prime * result + self.videosURL.hashValue
        result = prime * result + self.isWWDCWeek.hashValue
        return result
    }
}

func ==(lhs: AppConfigImpl, rhs: AppConfigImpl) -> Bool {
    return lhs.sessionsURL == rhs.sessionsURL
}
