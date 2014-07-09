//
//  AppConfigBuilder.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 04/07/16.
//  Copyright © 2016 Maksym Shcheglov. All rights reserved.
//

import Foundation
import SwiftyJSON

class AppConfigBuilder: EntityBuilder {

    typealias EntityType = AppConfig

    static func build(json: JSON) -> EntityType {
        var videosURL: NSURL? = nil
        if let videos = json["urls"]["videos"].string {
            videosURL = NSURL(string: videos)
        }

        var sessionsURL: NSURL? = nil
        if let sessions = json["urls"]["sessions"].string {
            sessionsURL = NSURL(string: sessions)
        }

        var isWWDCWeek = false
        if let streaming = json["features"]["liveStreaming"].bool {
            isWWDCWeek = streaming
        }

        return AppConfigImpl(sessionsURL: sessionsURL!, videosURL: videosURL!, isWWDCWeek: isWWDCWeek)
    }
    
}
