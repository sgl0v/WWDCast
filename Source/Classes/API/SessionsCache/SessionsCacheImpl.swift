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
    
    fileprivate let _sessions = Variable([Session]())
    fileprivate let database: Database
    lazy var sessions: Observable<[Session]> = {
        return self._sessions.asObservable()
    }()
    
    init(db: Database) {
        self.database = db
        createSessionsTable()
        reload()
    }
    
    func save(_ sessions: [Session]) {
        let sessionIds = Set(self._sessions.value.map({ $0.uniqueId }))
        let records = sessions.filter({ session in
            return !sessionIds.contains(session.uniqueId)
        }).map({ session in
            return SessionRecord(session: session)
        })
        if (records.isEmpty) {
            return
        }
        
        do {
            NSLog("Sessions.Insert: %lu;", records.count)
            try self.database.insert(records)
        } catch {
            NSLog("Failed to save sessions with error: \(error).")
        }
        reload()
    }
    
    func update(_ sessions: [Session]) {
        do {
            NSLog("Sessions.Update: %lu;", sessions.count)
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
        NSLog("Sessions.Loaded: %lu;", records.count)
//        NSLog("%@", sessions.description);
        return sessions
    }
    
    fileprivate func createSessionsTable() {
        do {
            try SessionTable.create(self.database)
        } catch {
            NSLog("Failed to create the sessions table with error: \(error).")
        }
    }
    
    fileprivate func reload() {
        self._sessions.value = load()
    }

}
