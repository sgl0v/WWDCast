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
    func create(_ table: String, block: (GRDB.TableDefinition) -> Void) throws
    
    func fetch<R: RowConvertible & TableMapping>() -> [R]
    
    func update(_ records: [Record]) throws
    
    func insert(_ records: [Record]) throws
    
    func delete(_ records: [Record]) throws
    
}
