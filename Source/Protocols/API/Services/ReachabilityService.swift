//
//  ReachabilityService.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 09/07/16.
//  Copyright © 2016 Maksym Shcheglov. All rights reserved.
//

import Foundation
import RxSwift

/**
 Defines the reachability status

 - Reachable:   The network is reachable via wifi/cellular network/etc.
 - Unreachable: The network is not reachable
 */
enum ReachabilityStatus {
    case reachable(viaWiFi: Bool)
    case unreachable
}

extension ReachabilityStatus {
    var reachable: Bool {
        switch self {
        case .reachable:
            return true
        case .unreachable:
            return false
        }
    }
}

protocol ReachabilityService: class {
    var reachability: Observable<ReachabilityStatus> { get }
}
