//
//  Database.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 30/10/2016.
//  Copyright © 2016 Maksym Shcheglov. All rights reserved.
//

import Foundation
import UIKit
import GRDB

final class DatabaseImpl: Database {
    
    let dbQueue: DatabaseQueue
    
    init?(path: String) {
        guard let dbQueue = try? DatabaseQueue(path: path) else {
            return nil
        }
        dbQueue.setupMemoryManagement(application: UIApplication.sharedApplication())
        self.dbQueue = dbQueue
    }
    
    func create(table: String, @noescape block: (GRDB.TableDefinition) -> Void) throws {
        try dbQueue.inDatabase({ db in
            try db.create(table: table, temporary: false, ifNotExists: true) { t in
                block(t)
            }
        })
    }
    
    func fetch<R: protocol<RowConvertible, TableMapping>>() -> [R] {
        var result = [R]()
        dbQueue.inDatabase({ db in
            result = R.fetchAll(db)
        })
        return result
    }
    
    func update(records: [Record]) throws {
        try perform(records) { record, db in
            try record.update(db)
        }
    }
    
    func insert(records: [Record]) throws {
        try perform(records) { record, db in
            try record.insert(db)
        }
    }
    
    func delete(records: [Record]) throws {
        try perform(records) { record, db in
            try record.delete(db)
        }
    }
    
    private func perform(records: [Record], @noescape block: (record: Record, db: GRDB.Database) throws -> Void) throws {
        try dbQueue.inTransaction { db in
            for record in records {
                try block(record: record, db: db)
            }
            return .Commit
        }
    }

}
