//
//  AppConfigBuilder.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 04/07/16.
//  Copyright © 2016 Maksym Shcheglov. All rights reserved.
//

import Foundation
import SwiftyJSON

class AppConfigBuilder: EntityBuilderType {

    typealias EntityType = AppConfig

    static func build(from data: Data) throws -> EntityType {
        let json = JSON(data)
        guard let videosURL = URL(string: json["urls"]["videos"].stringValue),
            let sessionsURL = URL(string: json["urls"]["sessions"].stringValue),
            let isWWDCWeek = json["features"]["liveStreaming"].bool else {
            throw EntityBuilderError.parsingError
        }
        return AppConfig(sessionsURL: sessionsURL, videosURL: videosURL, isWWDCWeek: isWWDCWeek)
    }

}
