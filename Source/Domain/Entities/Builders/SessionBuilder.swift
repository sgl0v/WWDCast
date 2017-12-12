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
        let media = json["media"]
        let captions = URL(string: media["subtitles"].stringValue)
        let video = URL(string: media["tvOShls"].string ?? media["downloadHD"].stringValue)
        let track = Session.Track(id: json["trackId"].intValue)
        let focus = json["platforms"].arrayObject ?? []
        let staticContentId = json["staticContentId"].intValue
        guard let eventYear = Int(json["eventId"].stringValue.replacingOccurrences(of: "wwdc", with: "")),
            let year = Session.Year(rawValue: eventYear),
            let type = Session.EventType(json["type"].stringValue),
            let thumbnailURL = self.imageURL(for: year, contentId: staticContentId) else {
            throw EntityBuilderError.parsingError
        }
        let id = json["id"].stringValue
        let contentId = json["eventContentId"].intValue
        let title = json["title"].stringValue
        let summary = json["description"].stringValue
        let duration = json["duration"].doubleValue

        let platforms: Session.Platform = focus.reduce([]) { (platforms, focusItem) -> Session.Platform in
            guard let platformName = focusItem as? String,
                let platform = Session.Platform(platformName) else {
                return platforms
            }
            return platforms.union(platform)
        }

        return Session(id: id, contentId: contentId, type: type, year: year, track: track, platforms: platforms,
                       title: title, summary: summary, video: video, captions: captions, duration: duration,
                           thumbnail: thumbnailURL, favorite: false)
    }

    private static func imageURL(`for` year: Session.Year, contentId: Int) -> URL? {
        let bucketMapping = [ Session.Year._2017: 7, Session.Year._2016: 1, Session.Year._2015: 2, Session.Year._2014: 3, Session.Year._2013: 4]
        guard let bucket = bucketMapping[year] else {
            return nil
        }
        var imageURL = Environment.appleCdnURL
        imageURL.appendPathComponent("images/\(bucket)/\(contentId)/\(contentId)_wide_900x506_1x.jpg")
        return imageURL

        // https://devimages-cdn.apple.com/wwdc-services/images/7/1729/1729_wide_250x141_2x.jpg ??
    }

}
