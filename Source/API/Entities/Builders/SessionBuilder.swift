//
//  SessionBuilder.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 04/07/16.
//  Copyright © 2016 Maksym Shcheglov. All rights reserved.
//

import Foundation
import SwiftyJSON

class SessionBuilder: EntityBuilderType {

    typealias EntityType = Session

    static func build(_ json: JSON) throws -> EntityType {
        let captions = URL(string: json["subtitles"].stringValue)
        let video = URL(string: json["download_hd"].stringValue)
        guard let year = Session.Year(rawValue: json["year"].intValue),
            let focus = json["focus"].arrayObject as? [String],
            let track = Session.Track(json["track"].stringValue),
            let images = json["images"].dictionaryObject as? [String: String],
            let thumbnailURLString = images["shelf"],
            let thumbnailURL = URL(string: thumbnailURLString) else {
            throw EntityBuilderError.parsingError
        }
        let id = json["id"].intValue
        let title = json["title"].stringValue
        let summary = json["description"].stringValue

        let platforms: Session.Platform = focus.reduce([]) { (platforms, focusItem) -> Session.Platform in
            guard let platform = Session.Platform(focusItem) else {
                return platforms
            }
            return platforms.union(platform)
        }

        return Session(id: id, year: year, track: track, platforms: platforms, title: title,
                           summary: summary, video: video, captions: captions,
                           thumbnail: thumbnailURL, favorite: false)
    }

}
