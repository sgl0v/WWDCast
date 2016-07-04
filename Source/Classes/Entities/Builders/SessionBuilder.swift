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

    static var dateFormatter: NSDateFormatter {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter
    }

    static func build(json: JSON) -> EntityType {
        var session = SessionImpl()

        session.id = json["id"].intValue
        session.year = json["year"].intValue
        session.uniqueId = "#" + String(session.year) + "-" + String(session.id)
        session.title = json["title"].stringValue
        session.summary = json["description"].stringValue
        session.date = self.dateFormatter.dateFromString(json["date"].stringValue)
        session.track = json["track"].stringValue
        session.videoURL = json["url"].stringValue
        session.hdVideoURL = json["download_hd"].stringValue
        session.slidesURL = json["slides"].stringValue
        session.track = json["track"].stringValue


        if let focus = json["focus"].arrayObject as? [String] {
            session.focus = focus.joinWithSeparator(", ")
        }

        if let images = json["images"].dictionaryObject as? [String: String] {
            session.shelfImageURL = images["shelf"] ?? ""
        }
        
        return session
    }
    
}
