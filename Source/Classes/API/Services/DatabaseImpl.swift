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

class ContentRepositoryQueryContext {
    
    private let db: GRDB.Database
    init(db: GRDB.Database) {
        self.db = db
    }
    
    func fetch<Record: RowConvertible & TableMapping & Persistable>() -> [Record] {
        return Record.fetchAll(self.db)
    }
    
}

class ContentRepositoryCommandContext {
    
    private let db: GRDB.Database
    init(db: GRDB.Database) {
        self.db = db
    }
    
    func create(table: SQLTable.Type) throws {
        try self.db.create(table: table.databaseTableName, temporary: false, ifNotExists: true) { t in
            table.defineColumns(table: t)
        }
    }
    
    func update<Record: RowConvertible & TableMapping & Persistable>(_ records: [Record]) throws {
        for record in records {
            try record.update(self.db)
        }
    }
    
    func insert<Record: RowConvertible & TableMapping & Persistable>(_ records: [Record]) throws {
        for record in records {
            try record.insert(self.db)
        }
    }
    
    func delete<Record: RowConvertible & TableMapping & Persistable>(_ records: [Record]) throws {
        for record in records {
            try record.delete(self.db)
        }
    }
    
    func deleteAll() throws {
        try Record.deleteAll(self.db)
    }
}

final class ContentRepositoryImpl {
    
    let dbQueue: DatabaseQueue
    
    init?(path: String) {
        guard let dbQueue = try? DatabaseQueue(path: path) else {
            return nil
        }
        dbQueue.setupMemoryManagement(in: UIApplication.shared)
        self.dbQueue = dbQueue
    }
    
    @discardableResult func perform(command: (ContentRepositoryCommandContext) throws -> ()) -> Bool {
        return perform(transaction: { db in
            try command(ContentRepositoryCommandContext(db: db))
        })
    }
    
    @discardableResult func perform(query: (ContentRepositoryQueryContext) throws -> ()) -> Bool {
        return perform(transaction: { db in
            try query(ContentRepositoryQueryContext(db: db))
        })
    }
    
    private func perform(transaction: (GRDB.Database) throws -> ()) -> Bool {
        var didFailTransaction = false
        do {
            try self.dbQueue.inTransaction { db in
                try transaction(db)
                return .commit
            }
        } catch {
            didFailTransaction = true
        }
        return !didFailTransaction
    }
}

final class DatabaseImpl: Database {
    
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
    
    @discardableResult private func perform(transaction: (GRDB.Database) throws -> ()) -> Bool {
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
