//
//  ServiceProviderProtocol.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 09/07/16.
//  Copyright © 2016 Maksym Shcheglov. All rights reserved.
//

import Foundation

protocol ServiceProviderProtocol: class {
    var reachability: ReachabilityServiceType { get }
    var network: NetworkServiceType { get }
    var googleCast: GoogleCastServiceType { get }
}
