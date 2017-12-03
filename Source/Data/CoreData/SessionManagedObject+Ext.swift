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
        guard let id = self.id, let title = self.title, let summary = self.summary,
            let thumbnail = self.thumbnail,
            let track = Session.Track(rawValue: Int(self.track)) else {
            fatalError("Failed to create \(Session.self) from \(self)!")
        }

        guard let year = Session.Year(rawValue: Int(self.year)),
            let type = Session.EventType(rawValue: Int(self.type)),
            let thumbnailUrl = URL(string: thumbnail) else {
                fatalError("Failed to create \(Session.self) from \(self)!")
        }

        let contentId = Int(self.contentId)
        let platforms = Session.Platform(rawValue: Int(self.platforms))
        let videoUrl = video.flatMap({ URL(string: $0) })
        let captionsUrl = captions.flatMap({ URL(string: $0) })
        let duration = TimeInterval(self.duration)
        return Session(id: id, contentId: contentId, type: type, year: year, track: track, platforms: platforms,
                       title: title, summary: summary, video: videoUrl, captions: captionsUrl, duration: duration,
                       thumbnail: thumbnailUrl, favorite: favorite)
    }

}
