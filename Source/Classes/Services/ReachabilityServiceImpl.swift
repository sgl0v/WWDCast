//
//  ReachabilityServiceImpl.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 09/07/16.
//  Copyright © 2016 Maksym Shcheglov. All rights reserved.
//

import Foundation
import RxSwift

final class ReachabilityServiceImpl: ReachabilityService {

    var reachability: Observable<ReachabilityStatus> {
        return _reachabilitySubject.asObservable()
    }

    private let _reachabilitySubject: BehaviorSubject<ReachabilityStatus>
    private let _reachability: Reachability

    init() throws {
        let reachabilityRef = try Reachability.reachabilityForInternetConnection()
        let reachabilitySubject = BehaviorSubject<ReachabilityStatus>(value: .Unreachable)

        // so main thread isn't blocked when reachability via WiFi is checked
        let backgroundQueue = dispatch_queue_create("reachability.wificheck", DISPATCH_QUEUE_SERIAL)

        reachabilityRef.whenReachable = { reachability in
            dispatch_async(backgroundQueue) {
                reachabilitySubject.on(.Next(.Reachable(viaWiFi: reachabilityRef.isReachableViaWiFi())))
            }
        }

        reachabilityRef.whenUnreachable = { reachability in
            dispatch_async(backgroundQueue) {
                reachabilitySubject.on(.Next(.Unreachable))
            }
        }

        try reachabilityRef.startNotifier()
        _reachability = reachabilityRef
        _reachabilitySubject = reachabilitySubject
    }

    deinit {
        _reachability.stopNotifier()
    }
}
