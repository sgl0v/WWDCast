//
//  Session+RecordConvertable.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 20/11/2016.
//  Copyright © 2016 Maksym Shcheglov. All rights reserved.
//

import Foundation

extension Session: RecordConvertable {
    typealias Record = SessionRecord
    
    func toRecord() -> Record {
        return SessionRecord(session: self)
    }
    
    init(record: Record) {
        self = record.session
    }
    
}
