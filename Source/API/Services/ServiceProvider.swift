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

    init(reachability: ReachabilityServiceProtocol, scheduler: SchedulerServiceProtocol, network: NetworkServiceProtocol, googleCast: GoogleCastServiceProtocol) {
        self.reachability = reachability
        self.scheduler = scheduler
        self.network = network
        self.googleCast = googleCast
    }
}

extension ServiceProvider {

    static let defaultServiceProvider: ServiceProviderProtocol = {
        guard let reachability = ReachabilityService() else {
            fatalError("Failed to create reachability service!")
        }

        // configure the logging service, that is available all over the project
        let consoleDestination = ConsoleDestination()
        Log.addDestination(consoleDestination)

        let scheduler = SchedulerService()
        let network = NetworkService()
        let googleCast = GoogleCastServiceProtocolImpl(applicationID: WWDCastEnvironment.googleCastAppID)

        return ServiceProvider(reachability: reachability, scheduler: scheduler, network: network, googleCast: googleCast)
    }()

}
