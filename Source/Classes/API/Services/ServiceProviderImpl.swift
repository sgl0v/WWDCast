//
//  ServiceProviderImpl.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 09/07/16.
//  Copyright © 2016 Maksym Shcheglov. All rights reserved.
//

import Foundation

final class ServiceProviderImpl: ServiceProvider {

    private(set) var reachability: ReachabilityService
    private(set) var scheduler: SchedulerService
    private(set) var network: NetworkService
    private(set) var googleCast: GoogleCastService
    private(set) var database: Database

    init(reachability: ReachabilityService, scheduler: SchedulerService, network: NetworkService, googleCast: GoogleCastService, database: Database) {
        self.reachability = reachability
        self.scheduler = scheduler
        self.network = network
        self.googleCast = googleCast
        self.database = database
    }
}

extension ServiceProviderImpl {
    
    static let defaultServiceProvider: ServiceProvider = {
        guard let reachability = try? ReachabilityServiceImpl() else {
            fatalError("Failed to create reachability service!")
        }
        
        let dbName = "db.sqlite"
        let fileManager = NSFileManager.defaultManager()
        guard let documentsURL = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first,
            let databasePath = documentsURL.URLByAppendingPathComponent(dbName)?.path,
            let database = DatabaseImpl(path: databasePath) else {
            fatalError("Failed to create database with name \(dbName)!")
        }
        
        let scheduler = SchedulerServiceImpl()
        let network = NetworkServiceImpl()
        let googleCast = GoogleCastServiceImpl(applicationID: WWDCEnvironment.googleCastAppID)
        return ServiceProviderImpl(reachability: reachability, scheduler: scheduler, network: network, googleCast: googleCast, database: database)
    }()

}
