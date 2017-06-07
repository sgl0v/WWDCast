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

        guard let year = Session.Year(rawValue: Int(self.year)),
            let thumbnailUrl = URL(string: thumbnail) else {
                fatalError("Failed to create \(Session.self) from \(self)!")
        }

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
