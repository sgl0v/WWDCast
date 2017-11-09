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
    private(set) var network: NetworkServiceProtocol
    private(set) var googleCast: GoogleCastServiceProtocol

    init(reachability: ReachabilityServiceProtocol, network: NetworkServiceProtocol, googleCast: GoogleCastServiceProtocol) {
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
        let googleCast = GoogleCastServiceProtocolImpl(applicationID: WWDCastEnvironment.googleCastAppID)

        return ServiceProvider(reachability: reachability, network: network, googleCast: googleCast)
    }()

}
