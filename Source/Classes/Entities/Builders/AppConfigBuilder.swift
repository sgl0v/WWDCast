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
        var config = AppConfigImpl()

        if let videos = json["urls"]["videos"].string {
            config.videosURL = videos
        }
        if let sessions = json["urls"]["sessions"].string {
            config.sessionsURL = sessions
        }

        if let streaming = json["features"]["liveStreaming"].bool {
            config.isWWDCWeek = streaming
        }

        return config
    }
    
}
