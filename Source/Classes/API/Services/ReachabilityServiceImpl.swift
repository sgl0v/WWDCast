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

    fileprivate let _reachabilitySubject: BehaviorSubject<ReachabilityStatus>
    fileprivate let _reachability: Reachability

    init() throws {
        let reachabilityRef = try Reachability.reachabilityForInternetConnection()
        let reachabilitySubject = BehaviorSubject<ReachabilityStatus>(value: .unreachable)

        reachabilityRef.whenReachable = { reachability in
            reachabilitySubject.on(.next(.reachable(viaWiFi: reachabilityRef.isReachableViaWiFi())))
        }

        reachabilityRef.whenUnreachable = { reachability in
            reachabilitySubject.on(.next(.unreachable))
        }

        try reachabilityRef.startNotifier()
        _reachability = reachabilityRef
        _reachabilitySubject = reachabilitySubject
    }

    deinit {
        _reachability.stopNotifier()
    }
}

extension NSError {
    func isConnectionError() -> Bool {
        let connectionErrorCodes = Set([NSURLErrorTimedOut, NSURLErrorCannotFindHost, NSURLErrorTimedOut, NSURLErrorCannotFindHost, NSURLErrorCannotConnectToHost, NSURLErrorNetworkConnectionLost, NSURLErrorNotConnectedToInternet, NSURLErrorDataNotAllowed])
        return self.domain == NSURLErrorDomain && connectionErrorCodes.contains(self.code)
    }
}

extension ObservableConvertibleType {
    func retryOnBecomesReachable(_ valueOnFailure:E, reachabilityService: ReachabilityService) -> Observable<E> {
        return self.asObservable()
//            .catchError { (e) -> Observable<E> in
//                reachabilityService.reachability
//                    .filter { $0.boolValue }
//                    .flatMap { _ in Observable.error(e) }
////                    .startWith(valueOnFailure)
//            }
//            .retry()
            .retryWhen { error -> Observable<E> in
                return error.flatMap({ (generatedError) -> Observable<E> in
                    let networkingError = generatedError as NSError
                    if networkingError.isConnectionError() {
                        return reachabilityService.reachability
                            .filter {
                                $0.boolValue
                            }
                            .flatMap { _ in self.asObservable() }
                    }
                    return Observable.error(generatedError)
                })
        }
    }
}
