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
        
        NSLog("Sessions.Insert: %lu;", records.count)
        if !self.database.insert(records) {
            NSLog("Failed to insert new sessions sessions!")
        }
        reload()
    }
    
    func update(_ sessions: [Session]) {
        NSLog("Sessions.Update: %lu;", sessions.count)
        let records = sessions.map() { SessionRecord(session: $0) }
        if !self.database.update(records) {
            NSLog("Failed to update cached sessions")
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
    
    private func createSessionsTable() {
        if !self.database.create(table: SessionTable.self) {
            NSLog("Failed to create the sessions table!")
        }
    }
    
    private func reload() {
        self._sessions.value = load()
    }

}
