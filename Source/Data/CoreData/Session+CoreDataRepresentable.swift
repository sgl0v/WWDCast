//
//  Session+CoreDataRepresentable.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 07/06/2017.
//  Copyright © 2017 Maksym Shcheglov. All rights reserved.
//

import Foundation

extension Session: CoreDataRepresentable {
    typealias CoreDataType = SessionManagedObject

    var uid: String {
        return self.id
    }

    func update(object: CoreDataType) {
        object.id = self.id
        object.type = Int16(self.type.rawValue)
        object.contentId = Int16(self.contentId)
        object.year = Int16(self.year.rawValue)
        object.track = Int16(self.track.rawValue)
        object.title = self.title
        object.summary = self.summary
        object.video = self.video.absoluteString
        object.captions = self.captions?.absoluteString
        object.duration = self.duration
        object.thumbnail = self.thumbnail.absoluteString
        object.favorite = self.favorite
        object.platforms = Int16(self.platforms.rawValue)
    }

}
