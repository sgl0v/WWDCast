//
//  DatabaseProtocol.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 30/10/2016.
//  Copyright © 2016 Maksym Shcheglov. All rights reserved.
//

import Foundation
import UIKit
import GRDB

/// A `Database` class provides access SQLite database. It is thread-safe and performs operations synchronously inside a transaction.
final class Database: DatabaseProtocol {

    let dbQueue: DatabaseQueue

    init?(path: String) {
        guard let dbQueue = try? DatabaseQueue(path: path) else {
            return nil
        }
        dbQueue.setupMemoryManagement(in: UIApplication.shared)
        self.dbQueue = dbQueue
    }

    func create(table: SQLTable.Type) -> Bool {
        return perform { db in
            try db.create(table: table.databaseTableName, temporary: false, ifNotExists: true) { t in
                table.defineColumns(table: t)
            }
        }
    }

    func fetch<R: RowConvertible & TableMapping>() -> [R] {
        var result = [R]()
        perform { db in
            result = R.fetchAll(db)
        }
        return result
    }

    func update(records: [Record]) -> Bool {
        return perform { db in
            for record in records {
                try record.save(db)
            }
        }
    }

    func insert(records: [Record]) -> Bool {
        return perform { db in
            for record in records {
                try record.insert(db)
            }
        }
    }

    func delete(records: [Record]) -> Bool {
        return perform { db in
            for record in records {
                try record.delete(db)
            }
        }
    }

    func deleteAll(ofType type: Record.Type) -> Bool {
        return perform { db in
            try type.deleteAll(db)
        }
    }

    @discardableResult private func perform(transaction: (GRDB.Database) throws -> Void) -> Bool {
        var didFailTransaction = false
        do {
            try self.dbQueue.inTransaction { db in
                try transaction(db)
                return .commit
            }
        } catch {
            NSLog("Failed to perform transaction with error: \(error)!")
            didFailTransaction = true
        }
        return !didFailTransaction
    }

}
