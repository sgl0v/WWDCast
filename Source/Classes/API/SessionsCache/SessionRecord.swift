//
//  SessionRecord.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 30/10/2016.
//  Copyright © 2016 Maksym Shcheglov. All rights reserved.
//

import Foundation
import GRDB

class SessionRecord: Record {
    
    let session: Session
    
    init(session: Session) {
        self.session = session
        super.init()
    }
    
    // MARK: Record overrides
    
    override class func databaseTableName() -> String {
        return "sessions"
    }
    
    required init(_ row: Row) {
        let id: Int = row.value(named: "id")
        let year: Int = row.value(named: "year")
        let track: String = row.value(named: "track")
        let allPlatforms: String = row.value(named: "platforms")
        let title: String = row.value(named: "title")
        let summary: String = row.value(named: "summary")
        let video: String = row.value(named: "video")
        let captions: String = row.value(named: "captions")
        let thumbnail: String = row.value(named: "thumbnail")
        let favorite: Bool = row.value(named: "favorite")
        
        let platforms = allPlatforms.componentsSeparatedByString("#").filter({ platform in
            return !platform.isEmpty
        }).map({ platform in
            return Platform(rawValue: platform)!
        })
        session = SessionImpl(id: id, year: Year(rawValue: UInt(year))!, track: Track(rawValue: track)!, platforms: platforms, title: title, summary: summary, video: NSURL(string: video)!, captions: NSURL(string: captions)!, thumbnail: NSURL(string: thumbnail)!, favorite: favorite)
        
        super.init(row)
    }
    
    override var persistentDictionary: [String : DatabaseValueConvertible?] {
        return ["id": session.id,
                "year": Int(session.year.rawValue),
                "track": session.track.rawValue,
                "platforms": session.platforms.isEmpty ? "" : session.platforms.map({ $0.rawValue }).joinWithSeparator("#"),
                "title": session.title,
                "summary": session.summary,
                "video": session.video.absoluteString,
                "captions": session.captions.absoluteString,
                "thumbnail": session.thumbnail.absoluteString,
                "favorite": session.favorite]
    }
    
}

protocol SQLTable: TableMapping {
    static func create(db: Database) throws -> Void
}

extension SessionRecord: SQLTable {
    
    class func create(db: Database) throws {
        try db.create(self.databaseTableName()) { table in
            table.column("id", .Integer)
            table.column("year", .Integer)
            table.column("track", .Text).notNull()
            table.column("platforms", .Text).notNull()
            table.column("title", .Text).notNull()
            table.column("summary", .Text).notNull()
            table.column("video", .Text).notNull()
            table.column("captions", .Text).notNull()
            table.column("thumbnail", .Text).notNull()
            table.column("favorite", .Boolean).notNull().defaults(to: false)
            table.primaryKey(["id", "year"])
        }
    }
    
}
