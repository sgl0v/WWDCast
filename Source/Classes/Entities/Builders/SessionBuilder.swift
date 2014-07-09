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
        let year = json["year"].intValue 
        let title = json["title"].stringValue
        let summary = json["description"].stringValue
        let track = Track(rawValue: json["track"].stringValue)!
        let videoURL = NSURL(string: json["url"].stringValue)!
        let hdVideoURL = NSURL(string: json["download_hd"].stringValue)!

        var focus = [Focus]()
        if let focusJSON = json["focus"].arrayObject as? [String] {
            focus = focusJSON.map() { Focus(rawValue: $0)! }
        }

        var shelfImageURL: NSURL? = nil
        if let images = json["images"].dictionaryObject as? [String: String], imageURL = images["shelf"] {
            shelfImageURL = NSURL(string: imageURL)!
        }
        
        return SessionImpl(id: id, year: year, track: track, focus: focus, title: title,
                           summary: summary, videoURL: videoURL, hdVideoURL: hdVideoURL, shelfImageURL: shelfImageURL!)
    }
    
}
