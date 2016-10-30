//
//  SessionsCacheImpl.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 21/10/2016.
//  Copyright © 2016 Maksym Shcheglov. All rights reserved.
//

import Foundation
import RxSwift

class SessionsCacheImpl: SessionsCache {
    
    private let _sessions = Variable([Session]())
    private let database: Database
    lazy var sessions: Observable<[Session]> = {
        self.reload()
        return self._sessions.asObservable()
    }()
    
    init(db: Database) {
        self.database = db
        reload()
    }
    
    func save(sessions: [Session]) {
        do {
            try SessionRecord.create(self.database)
            let records = sessions.map() { SessionRecord(session: $0) }
            try self.database.delete(records)
            try self.database.insert(records)
        } catch {
            NSLog("Failed to save sessions with error: \(error).")
        }
//        NSLog("%@", sessions.description);
        reload()
    }
    
    func update(sessions: [Session]) {
        do {
            let records = sessions.map() { SessionRecord(session: $0) }
            try self.database.update(records)
        } catch {
            NSLog("Failed to update cached session with error: \(error).")
        }
        reload()
    }
    
    func load() -> [Session] {
        let records: [SessionRecord] = self.database.fetch()
        let sessions = records.map() { session in
            return session.session
        }
//        NSLog("%@", sessions.description);
        return sessions
    }
    
    private func reload() {
        self._sessions.value = load()
    }

}
