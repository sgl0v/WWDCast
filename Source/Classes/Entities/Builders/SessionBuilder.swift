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

    static func build(json: JSON) -> EntityType {
        let id = json["id"].intValue
        let year = Year(rawValue: json["year"].uIntValue)!
        let title = json["title"].stringValue
        let summary = json["description"].stringValue
        let track = Track(rawValue: json["track"].stringValue)!
        let videoURL = NSURL(string: json["download_hd"].stringValue)!
//        let hdVideoURL = NSURL(string: json["download_hd"].stringValue)!
//        let sdVideoURL = NSURL(string: json["download_sd"].stringValue)!
//        let webpageURL = NSURL(string: json["webpageURL"].stringValue)!
        let subtitles = NSURL(string: json["subtitles"].stringValue)!

        var platforms = [Platform]()
        if let focusJSON = json["focus"].arrayObject as? [String] {
            platforms = focusJSON.map() { Platform(rawValue: $0)! }
        }

        var shelfImageURL: NSURL? = nil
        if let images = json["images"].dictionaryObject as? [String: String], imageURL = images["shelf"] {
            shelfImageURL = NSURL(string: imageURL)!
        }
        
        return SessionImpl(id: id, year: year, track: track, platforms: platforms, title: title,
                           summary: summary, videoURL: videoURL, subtitles: subtitles,
                           shelfImageURL: shelfImageURL!)
    }
    
}
