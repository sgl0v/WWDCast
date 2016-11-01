//
//  ServiceProviderImpl.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 09/07/16.
//  Copyright © 2016 Maksym Shcheglov. All rights reserved.
//

import Foundation

final class ServiceProviderImpl: ServiceProvider {

    fileprivate(set) var reachability: ReachabilityService
    fileprivate(set) var scheduler: SchedulerService
    fileprivate(set) var network: NetworkService
    fileprivate(set) var googleCast: GoogleCastService
    fileprivate(set) var database: Database

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
        let fileManager = FileManager.default
        guard let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first,
            let database = DatabaseImpl(path: documentsURL.appendingPathComponent(dbName).path) else {
            fatalError("Failed to create database with name \(dbName)!")
        }
        
        let scheduler = SchedulerServiceImpl()
        let network = NetworkServiceImpl()
        let googleCast = GoogleCastServiceImpl(applicationID: WWDCEnvironment.googleCastAppID)
        return ServiceProviderImpl(reachability: reachability, scheduler: scheduler, network: network, googleCast: googleCast, database: database)
    }()

}
