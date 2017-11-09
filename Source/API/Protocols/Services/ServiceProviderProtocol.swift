//
//  ServiceProviderProtocol.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 09/07/16.
//  Copyright © 2016 Maksym Shcheglov. All rights reserved.
//

import Foundation

protocol ServiceProviderProtocol: class {
    var reachability: ReachabilityServiceProtocol { get }
    var network: NetworkServiceProtocol { get }
    var googleCast: GoogleCastServiceProtocol { get }
}
