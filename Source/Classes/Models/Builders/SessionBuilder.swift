//
//  SessionBuilder.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 04/07/16.
//  Copyright © 2016 Maksym Shcheglov. All rights reserved.
//

import Foundation
import SwiftyJSON

class SessionBuilder: EntityBuilder {

    typealias EntityType = Session

    static func build(_ json: JSON) throws -> EntityType {
        let captions = URL(string: json["subtitles"].stringValue)
        let video = URL(string: json["download_hd"].stringValue)
        guard let year = Session.Year(rawValue: json["year"].uIntValue),
            let track = Session.Track(rawValue: json["track"].stringValue),
            let focusJSON = json["focus"].arrayObject as? [String],
            let images = json["images"].dictionaryObject as? [String: String],
            let thumbnailURLString = images["shelf"],
            let thumbnailURL = URL(string: thumbnailURLString) else {
            throw EntityBuilderError.parsingError
        }
        let id = json["id"].intValue
        let title = json["title"].stringValue
        let summary = json["description"].stringValue

        var platforms = Array<Session.Platform>()
        platforms = try focusJSON.map() { focus in
            guard let platform = Session.Platform(rawValue: focus) else {
                throw EntityBuilderError.parsingError
            }
            return platform
        }

        return Session(id: id, year: year, track: track, platforms: platforms, title: title,
                           summary: summary, video: video, captions: captions,
                           thumbnail: thumbnailURL, favorite: false)
    }
    
}
