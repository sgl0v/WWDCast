//
//  SessionManagedObject+Ext.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 22/05/2017.
//  Copyright © 2017 Maksym Shcheglov. All rights reserved.
//

import Foundation

extension SessionManagedObject: EntityRepresentable {
    typealias EntityType = Session

    func asEntity() -> Session {
        guard let title = self.title, let summary = self.summary,
            let thumbnail = self.thumbnail, let allPlatforms = self.platforms else {
            fatalError("Failed to create \(Session.self) from \(self)!")
        }

//        @NSManaged public var id: String?
//        @NSManaged public var year: Int16
//        @NSManaged public var track: Int16
//        @NSManaged public var title: String?
//        @NSManaged public var summary: String?
//        @NSManaged public var video: String?
//        @NSManaged public var captions: String?
//        @NSManaged public var thumbnail: String?
//        @NSManaged public var favorite: Bool
//        @NSManaged public var platforms: String?
//
//
        guard let year = Session.Year(rawValue: Int(self.year)),
            let thumbnailUrl = URL(string: thumbnail) else {
                fatalError("Failed to create \(Session.self) from \(self)!")
        }
//
//        let id: Int = row.value(named: "id")
//        let track: Int = row.value(named: "track")
//        let allPlatforms: String = row.value(named: "platforms")
//        let title: String = row.value(named: "title")
//        let summary: String = row.value(named: "summary")
//        let video: String? = row.value(named: "video")
//        let captions: String? = row.value(named: "captions")
//        let favorite: Bool = row.value(named: "favorite")
//
        let platforms: [Session.Platform] = allPlatforms.components(separatedBy: "#").filter({ platform in
            return !platform.isEmpty
        }).map({ value in
            guard let platform = Session.Platform(rawValue: value) else {
                fatalError("Failed to create \(Session.Platform.self) from \(value)")
            }
            return platform
        })
        let videoUrl = video.flatMap({ URL(string: $0) })
        let captionsUrl = captions.flatMap({ URL(string: $0) })
        return Session(id: Int(id), year: year, track: Session.Track(rawValue: Int(track)), platforms: platforms,
                          title: title, summary: summary, video: videoUrl, captions: captionsUrl, thumbnail: thumbnailUrl,
                          favorite: favorite)
    }

}

