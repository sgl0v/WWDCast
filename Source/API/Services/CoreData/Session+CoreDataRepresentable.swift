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
        return self.uniqueId
    }

    func update(object: CoreDataType) {
        object.uniqueId = self.uniqueId
        object.id = Int16(self.id)
        object.year = Int16(self.year.rawValue)
        object.track = Int16(self.track.rawValue)
        object.title = self.title
        object.summary = self.summary
        object.video = self.video?.absoluteString
        object.captions = self.captions?.absoluteString
        object.thumbnail = self.thumbnail.absoluteString
        object.favorite = self.favorite
        object.platforms = self.platforms.isEmpty ? "" : self.platforms.map({ $0.rawValue }).joined(separator: "#")
    }
    
}
