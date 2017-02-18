//
//  DatabaseProtocol.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 30/10/2016.
//  Copyright © 2016 Maksym Shcheglov. All rights reserved.
//

import Foundation
import GRDB

protocol RecordConvertable {
    associatedtype Record
    func toRecord() -> Record
    init(record: Record)
}

protocol SQLTable: TableMapping {

    static func defineColumns(table: GRDB.TableDefinition) -> Void
}

/// A `DatabaseProtocol` protocol defines methods to access database via CRUD operations.
protocol DatabaseProtocol {

    /// Creates a table with specified name
    ///
    /// - Parameter table: The name of the table
    /// - Returns: true if the operation succeeded, false otherwise
    @discardableResult func create(table: SQLTable.Type) -> Bool

    /// Fetches records of type R from the database
    ///
    /// - Returns: An array of records
    func fetch<R: RowConvertible & TableMapping>() -> [R]

    /// Updates records in the database.
    ///
    /// - Parameter records: an array of records to update.
    /// - Returns: true if the operation succeeded, false otherwise.
    @discardableResult func update(records: [Record]) -> Bool

    /// Inserts records in the database.
    ///
    /// - Parameter records: an array of records to insert.
    /// - Returns: true if the operation succeeded, false otherwise.
    @discardableResult func insert(records: [Record]) -> Bool

    /// Deletes records in the database.
    ///
    /// - Parameter records: an array of records to delete.
    /// - Returns: true if the operation succeeded, false otherwise.
    @discardableResult func delete(records: [Record]) -> Bool

    /// Deletes all records of specified type.
    ///
    /// - Parameter type: the type of the record
    /// - Returns: true if the operation succeeded, false otherwise.
    @discardableResult func deleteAll(ofType type: Record.Type) -> Bool

}
