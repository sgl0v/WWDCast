//
//  NetworkDataSource.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 07/06/2017.
//  Copyright © 2017 Maksym Shcheglov. All rights reserved.
//

import Foundation
import RxSwift

final class NetworkDataSource: DataSourceType {
    typealias Item = Session

    private let reachability: ReachabilityServiceType
    private let network: NetworkServiceType

    init(network: NetworkServiceType, reachability: ReachabilityServiceType) {
        self.network = network
        self.reachability = reachability
    }

    func allObjects() -> Observable<[Item]> {
        return self.loadSessions()
            .retryOnBecomesReachable([], reachabilityService: self.reachability)
            .share(replay: 1)
    }

    func get(byId id: String) -> Observable<Item> {
        // Currently not supported
        return Observable.empty()
    }

    func add(_ items: [Item]) -> Observable<[Item]> {
        // Currently not supported
        return Observable.empty()
    }

    func update(_ items: [Item]) -> Observable<[Item]> {
        // Currently not supported
        return Observable.empty()
    }

    func clean() -> Observable<Void> {
        // Currently not supported
        return Observable.empty()
    }

    func delete(byId id: String) -> Observable<Void> {
        // Currently not supported
        return Observable.empty()
    }

    // MARK: Private

    private func loadSessions() -> Observable<[Session]> {
        let sessionsResource = Resource(url: Environment.sessionsURL, parser: SessionsBuilder.build)
        return self.network.load(sessionsResource)
    }

}
