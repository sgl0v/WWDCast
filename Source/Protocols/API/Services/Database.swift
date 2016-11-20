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
    
    @discardableResult func create(table: SQLTable.Type) -> Bool
    
    func fetch<R: RowConvertible & TableMapping>() -> [R]
    
    @discardableResult func update(_ records: [Record]) -> Bool
    
    @discardableResult func insert(_ records: [Record]) -> Bool
    
    @discardableResult func delete(_ records: [Record]) -> Bool
    
    @discardableResult func deleteAll(ofType type: Record.Type) -> Bool
    
}
