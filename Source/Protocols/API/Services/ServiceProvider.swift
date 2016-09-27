//
//  ServiceProvider.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 09/07/16.
//  Copyright © 2016 Maksym Shcheglov. All rights reserved.
//

import Foundation

protocol ServiceProvider: class {
    var reachability: ReachabilityService { get }
    var scheduler: SchedulerService { get }
    var network: NetworkService { get }
    var googleCast: GoogleCastService { get }
}
