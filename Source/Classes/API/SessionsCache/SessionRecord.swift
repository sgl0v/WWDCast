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

    override static var databaseTableName: String {
        return SessionTable.databaseTableName
    }

    required init(row: Row) {
        guard let year = Session.Year(rawValue: row.value(named: "year")),
            let thumbnail = URL(string: row.value(named: "thumbnail")) else {
                fatalError("Failed to create \(SessionRecord.self) from \(row)!")
        }

        let id: Int = row.value(named: "id")
        let track: Int = row.value(named: "track")
        let allPlatforms: String = row.value(named: "platforms")
        let title: String = row.value(named: "title")
        let summary: String = row.value(named: "summary")
        let video: String? = row.value(named: "video")
        let captions: String? = row.value(named: "captions")
        let favorite: Bool = row.value(named: "favorite")

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
        session = Session(id: id, year: year, track: Session.Track(rawValue: track), platforms: platforms,
                          title: title, summary: summary, video: videoUrl, captions: captionsUrl, thumbnail: thumbnail,
                          favorite: favorite)

        super.init(row: row)
    }

    override var persistentDictionary: [String : DatabaseValueConvertible?] {
        return ["id": session.id,
                "year": session.year.rawValue,
                "track": session.track.rawValue,
                "platforms": session.platforms.isEmpty ? "" : session.platforms.map({ $0.rawValue }).joined(separator: "#"),
                "title": session.title,
                "summary": session.summary,
                "video": session.video?.absoluteString,
                "captions": session.captions?.absoluteString,
                "thumbnail": session.thumbnail.absoluteString,
                "favorite": session.favorite]
    }

}

class SessionTable: SQLTable {

    /// The name of the database table
    static let databaseTableName = "sessions"

    static func defineColumns(table: GRDB.TableDefinition) {
        table.column("id", .integer)
        table.column("year", .integer)
        table.column("track", .integer).notNull()
        table.column("platforms", .text).notNull()
        table.column("title", .text).notNull()
        table.column("summary", .text).notNull()
        table.column("video", .text)
        table.column("captions", .text)
        table.column("thumbnail", .text).notNull()
        table.column("favorite", .boolean).notNull().defaults(to: false)
        table.primaryKey(["id", "year"])
    }

}
