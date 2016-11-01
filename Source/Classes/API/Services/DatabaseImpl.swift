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
        dbQueue.setupMemoryManagement(in: UIApplication.shared)
        self.dbQueue = dbQueue
    }
    
    func create(_ table: String, block: (GRDB.TableDefinition) -> Void) throws {
        try dbQueue.inDatabase({ db in
            try db.create(table: table, temporary: false, ifNotExists: true) { t in
                block(t)
            }
        })
    }
    
    func fetch<R: RowConvertible & TableMapping>() -> [R] {
        var result = [R]()
        dbQueue.inDatabase({ db in
            result = R.fetchAll(db)
        })
        return result
    }
    
    func update(_ records: [Record]) throws {
        try perform(records) { record, db in
            try record.update(db)
        }
    }
    
    func insert(_ records: [Record]) throws {
        try perform(records) { record, db in
            try record.insert(db)
        }
    }
    
    func delete(_ records: [Record]) throws {
        try perform(records) { record, db in
            try record.delete(db)
        }
    }
    
    fileprivate func perform(_ records: [Record], block: (_ record: Record, _ db: GRDB.Database) throws -> Void) throws {
        try dbQueue.inTransaction { db in
            for record in records {
                try block(record, db)
            }
            return .commit
        }
    }

}
