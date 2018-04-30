//
//  RemoteRepository.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 07/06/2017.
//  Copyright © 2017 Maksym Shcheglov. All rights reserved.
//

import Foundation
import RxSwift

final class RemoteRepository: RepositoryType {
    typealias Element = [Session]

    private let reachability: ReachabilityServiceType
    private let network: NetworkServiceType

    init(network: NetworkServiceType, reachability: ReachabilityServiceType) {
        self.network = network
        self.reachability = reachability
    }

    func asObservable() -> Observable<Element> {
        return self.loadSessions()
            .retryOnBecomesReachable([], reachabilityService: self.reachability)
    }

    func add(_ value: Element) -> Observable<Element> {
        // Currently not supported
        return Observable.empty()
    }

    func update(_ value: Element) -> Observable<Element> {
        // Currently not supported
        return Observable.empty()
    }

    func clean() -> Observable<Void> {
        // Currently not supported
        return Observable.empty()
    }

    // MARK: Private

    private func loadSessions() -> Observable<[Session]> {
        let sessionsResource = Resource(url: Environment.sessionsURL, parser: SessionsBuilder.build)
        return self.network.load(sessionsResource)
    }

}
