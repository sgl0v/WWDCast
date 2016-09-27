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
public enum ReachabilityStatus {
    case Reachable(viaWiFi: Bool)
    case Unreachable
}

// Conform the ReachabilityStatus to BooleanType protocol and make it usable as the condition in control statements
extension ReachabilityStatus: BooleanType {

    public var boolValue: Bool {
        if case .Reachable = self {
            return true
        }
        return false
    }
}

protocol ReachabilityService: class {
    var reachability: Observable<ReachabilityStatus> { get }
}

