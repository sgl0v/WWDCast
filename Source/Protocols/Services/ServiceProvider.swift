//
//  ServiceProvider.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 09/07/16.
//  Copyright © 2016 Maksym Shcheglov. All rights reserved.
//

import Foundation

protocol ServiceProvider: class {
    var reachabilityService: ReachabilityService { get }
    var schedulerService: SchedulerService { get }
    var networkService: NetworkService { get }
}
