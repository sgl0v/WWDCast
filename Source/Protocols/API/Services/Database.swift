//
//  Database.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 30/10/2016.
//  Copyright © 2016 Maksym Shcheglov. All rights reserved.
//

import Foundation
import GRDB

protocol Database {
    func create(table: String, @noescape block: (GRDB.TableDefinition) -> Void) throws
    
    func fetch<R: protocol<RowConvertible, TableMapping>>() -> [R]
    
    func update(records: [Record]) throws
    
    func insert(records: [Record]) throws
    
    func delete(records: [Record]) throws
    
}
