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

    static func build(json: JSON) throws -> EntityType {
        guard let videosURL = NSURL(string: json["urls"]["videos"].stringValue),
            let sessionsURL = NSURL(string: json["urls"]["sessions"].stringValue),
            let isWWDCWeek = json["features"]["liveStreaming"].bool else {
            throw EntityBuilderError.ParsingError
        }
        return AppConfigImpl(sessionsURL: sessionsURL, videosURL: videosURL, isWWDCWeek: isWWDCWeek)
    }
    
}
