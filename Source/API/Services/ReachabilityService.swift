//
//  ReachabilityService.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 09/07/16.
//  Copyright © 2016 Maksym Shcheglov. All rights reserved.
//

import Foundation
import RxSwift

final class ReachabilityService: ReachabilityServiceProtocol {

    var reachability: Observable<ReachabilityStatus> {
        return _reachabilitySubject.asObservable()
    }

    private let _reachabilitySubject: BehaviorSubject<ReachabilityStatus>
    private let _reachability: Reachability

    init?() {
        guard let reachabilityRef = Reachability() else {
            return nil
        }
        let reachabilitySubject = BehaviorSubject<ReachabilityStatus>(value: .unreachable)

        reachabilityRef.whenReachable = { reachability in
            reachabilitySubject.on(.next(.reachable(viaWiFi: reachabilityRef.isReachableViaWiFi)))
        }

        reachabilityRef.whenUnreachable = { reachability in
            reachabilitySubject.on(.next(.unreachable))
        }

        do {
            try reachabilityRef.startNotifier()
        } catch {
            return nil
        }

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
    func retryOnBecomesReachable(_ valueOnFailure: E, reachabilityService: ReachabilityServiceProtocol) -> Observable<E> {
        return self.asObservable()
            .retryWhen { error -> Observable<E> in
                return error.flatMap({ (generatedError) -> Observable<E> in
                    let networkingError = generatedError as NSError
                    if !networkingError.isConnectionError() {
                        return Observable.error(generatedError)
                    }
                    return reachabilityService.reachability
                        .filter {
                            $0.reachable
                        }
                        .flatMap { _ in Observable.just(valueOnFailure) }
                })
        }
    }
}
