//
//  Database.swift
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

protocol Database {
    
    @discardableResult func create(table: SQLTable.Type) -> Bool
    
    func fetch<R: RowConvertible & TableMapping>() -> [R]
    
    @discardableResult func update(records: [Record]) -> Bool
    
    @discardableResult func insert(records: [Record]) -> Bool
    
    @discardableResult func delete(records: [Record]) -> Bool
    
    @discardableResult func deleteAll(ofType type: Record.Type) -> Bool
    
}
