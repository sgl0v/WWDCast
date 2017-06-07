//
//  ServiceProvider.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 09/07/16.
//  Copyright © 2016 Maksym Shcheglov. All rights reserved.
//

import Foundation
import RxSwift

final class ServiceProvider: ServiceProviderProtocol {

    private(set) var reachability: ReachabilityServiceProtocol
    private(set) var scheduler: SchedulerServiceProtocol
    private(set) var network: NetworkServiceProtocol
    private(set) var googleCast: GoogleCastServiceProtocol
//    private(set) var database: DatabaseProtocol

    init(reachability: ReachabilityServiceProtocol, scheduler: SchedulerServiceProtocol, network: NetworkServiceProtocol, googleCast: GoogleCastServiceProtocol) {
        self.reachability = reachability
        self.scheduler = scheduler
        self.network = network
        self.googleCast = googleCast
//        self.database = database
    }
}

extension ServiceProvider {

    static let defaultServiceProviderProtocol: ServiceProviderProtocol = {
        guard let reachability = ReachabilityService() else {
            fatalError("Failed to create reachability service!")
        }

//        let dbName = "db.sqlite"
//        let fileManager = FileManager.default
//        guard let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first,
//            let database = Database(path: documentsURL.appendingPathComponent(dbName).path) else {
//            fatalError("Failed to create database with name \(dbName)!")
//        }

        let scheduler = SchedulerService()
        let network = NetworkService()
        let googleCast = GoogleCastServiceProtocolImpl(applicationID: WWDCastEnvironment.googleCastAppID)

        return ServiceProvider(reachability: reachability, scheduler: scheduler, network: network, googleCast: googleCast)
    }()

}
