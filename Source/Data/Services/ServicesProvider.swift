//
//  ServicesProvider.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 05/01/2018.
//  Copyright © 2018 Maksym Shcheglov. All rights reserved.
//

import Foundation

struct ServicesProvider {

    let googleCast: GoogleCastService
    let network: NetworkService
    let reachability: ReachabilityService

    static func defaultProvider() -> ServicesProvider {
        let googleCast = GoogleCastService(applicationID: Environment.googleCastAppID)
        let network = NetworkService()
        guard let reachability = ReachabilityService() else {
            fatalError("Failed to create reachability service!")
        }
        #if DEBUG
        // configure the logging service, that is available all over the project
        let consoleDestination = ConsoleDestination()
        Log.addDestination(consoleDestination)
        #endif
        return ServicesProvider(googleCast: googleCast, network: network, reachability: reachability)
    }

}
