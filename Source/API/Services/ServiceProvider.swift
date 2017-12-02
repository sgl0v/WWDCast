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

    private(set) var reachability: ReachabilityServiceType
    private(set) var network: NetworkServiceType
    private(set) var googleCast: GoogleCastServiceType

    init(reachability: ReachabilityServiceType, network: NetworkServiceType, googleCast: GoogleCastServiceType) {
        self.reachability = reachability
        self.network = network
        self.googleCast = googleCast
    }
}

extension ServiceProvider {

    static let defaultServiceProviderProtocol: ServiceProviderProtocol = {
        guard let reachability = ReachabilityService() else {
            fatalError("Failed to create reachability service!")
        }

        let network = NetworkService()
        let googleCast = GoogleCastService(applicationID: WWDCastEnvironment.googleCastAppID)

        return ServiceProvider(reachability: reachability, network: network, googleCast: googleCast)
    }()

}
