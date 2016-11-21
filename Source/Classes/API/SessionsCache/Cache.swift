//
//  SessionsCacheImpl.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 21/10/2016.
//  Copyright © 2016 Maksym Shcheglov. All rights reserved.
//

import Foundation
import RxSwift
import GRDB

class Cache<Element: RecordConvertable & Equatable> where Element.Record : GRDB.Record {
    private let _values = Variable([Element]())
    private let database: Database
    lazy var values: Observable<[Element]> = {
        self.reload()
        return self._values.asObservable()
    }()
    
    init(db: Database) {
        self.database = db
    }
    
    func load() -> [Element] {
        let records: [Element.Record] = self.database.fetch()
        let values = records.map() { record in
            return Element(record: record)
        }
        NSLog("Cache.Loaded: \(records.count);")
        //        NSLog("%@", values.description);
        return values
    }
    
    func add(values: [Element]) {
        if (values.isEmpty) {
            return
        }
        let records = values.map { value in
            return value.toRecord()
        }
        
        NSLog("Cache.Add: \(records.count);")
        if !self.database.insert(records: records) {
            NSLog("Failed to insert new values to the cache!")
        }
        reload()
    }
    
    func remove(values: [Element]) {
        if (values.isEmpty) {
            return
        }
        let records = values.map { value in
            return value.toRecord()
        }
        
        NSLog("Cache.Remove: \(records.count);")
        if !self.database.delete(records: records) {
            NSLog("Failed to delete values from the cache!")
        }
        reload()
    }
    
    func update(values: [Element]) {
        if (values.isEmpty) {
            return
        }

        NSLog("Cache.Update: %lu;", values.count)
        let records = values.map { value in
            return value.toRecord()
        }
        if !self.database.update(records: records) {
            NSLog("Failed to update cached values!")
        }
        reload()
    }
    
    func clean() {
        self.database.deleteAll(ofType: Element.Record.self)
        reload()
    }
    
    private func reload() {
        self._values.value = load()
    }
}
