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

    typealias Input = JSON
    typealias EntityType = Session

    static func build(from json: JSON) throws -> EntityType {
        let media = json["media"]
        let captions = URL(string: media["subtitles"].stringValue)
        let track = try self.track(from: json["topicIds"].arrayObject ?? [])
        let platforms = self.platforms(from: json["platforms"].arrayObject ?? [])
        let staticContentId = json["staticContentId"].intValue
        let year = try self.year(from: json["eventId"].stringValue)
        let thumbnailURL = try self.imageURL(for: year, contentId: staticContentId)
        guard let type = Session.EventType(json["type"].stringValue),
            let video = URL(string: media["tvOShls"].string ?? media["downloadHD"].stringValue) else {
            throw EntityBuilderError.parsingError
        }
        let id = json["id"].stringValue
        let contentId = json["eventContentId"].intValue
        let title = json["title"].stringValue
        let summary = json["description"].stringValue
        let duration = media["duration"].doubleValue
        return Session(id: id, contentId: contentId, type: type, year: year, track: track, platforms: platforms,
                       title: title, summary: summary, video: video, captions: captions, duration: duration,
                           thumbnail: thumbnailURL, favorite: false)
    }

    private static func year(from eventId: String) throws -> Session.Year {
        let eventsMap: [String: Session.Year] = ["wwdc2018": ._2018, "insights": ._2018, "tech-talks": ._2017, "wwdc2017": ._2017,
                                                 "wwdc2016": ._2016, "wwdc2015": ._2015, "wwdc2014": ._2014]

        guard let year = eventsMap[eventId] else {
            throw EntityBuilderError.parsingError
        }
        return year
    }

    private static func track(from topicsJson: [Any]) throws -> Session.Track {
        let topics = topicsJson.compactMap({ (value) -> Session.Topic? in
            guard let intValue = value as? Int, let topic = Session.Topic(rawValue: intValue) else {
                return nil
            }
            return topic
        })
        let tracks = topics.flatMap { (topic) -> [Session.Track] in
            return Session.Track.all.filter({ track in
                return track.topics().contains(topic)
            })
        }
        guard let track = tracks.first else {
            throw EntityBuilderError.parsingError
        }
        return track
    }

    private static func platforms(from json: [Any]) -> Session.Platform {
        return json.reduce([]) { (platforms, focusItem) -> Session.Platform in
            guard let platformName = focusItem as? String,
                let platform = Session.Platform(platformName) else {
                    return platforms
            }
            return platforms.union(platform)
        }
    }

    private static func imageURL(`for` year: Session.Year, contentId: Int) throws -> URL {
        let bucketMapping = [ Session.Year._2018: 42, Session.Year._2017: 7, Session.Year._2016: 1, Session.Year._2015: 2,
                              Session.Year._2014: 3, Session.Year._2013: 4]
        guard let bucket = bucketMapping[year] else {
            throw EntityBuilderError.parsingError
        }
        var imageURL = Environment.appleCdnURL
        imageURL.appendPathComponent("images/\(bucket)/\(contentId)/\(contentId)_wide_900x506_1x.jpg")
        return imageURL
    }

}
