//
//  ServiceProviderImpl.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 09/07/16.
//  Copyright © 2016 Maksym Shcheglov. All rights reserved.
//

import Foundation

final class ServiceProviderImpl: ServiceProvider {

    private(set) var reachabilityService: ReachabilityService
    private(set) var schedulerService: SchedulerService
    private(set) var networkService: NetworkService

    init(reachabilityService: ReachabilityService, schedulerService: SchedulerService, networkService: NetworkService) {
        self.reachabilityService = reachabilityService
        self.schedulerService = schedulerService
        self.networkService = networkService
    }
}

extension ServiceProvider {

    static func defaultServiceProvider() -> ServiceProvider {
        guard let reachabilityService = try? ReachabilityServiceImpl() else {
            fatalError("Failed to create reachability service!")
        }
        let schedulerService = SchedulerServiceImpl()
        let networkService = NetworkServiceImpl()
        return ServiceProviderImpl(reachabilityService: reachabilityService, schedulerService: schedulerService, networkService: networkService)
    }

}
