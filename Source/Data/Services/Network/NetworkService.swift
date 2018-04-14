//
//  NetworkService.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 09/07/16.
//  Copyright © 2016 Maksym Shcheglov. All rights reserved.
//

import Foundation
import RxSwift
import SwiftyJSON

final class NetworkService: NetworkServiceType {

    private let session: URLSession
    private static func defaultConfiguration() -> URLSessionConfiguration {
        let configuration = URLSessionConfiguration.default
        configuration.allowsCellularAccess = false
        return configuration
    }

    init(session: URLSession = URLSession(configuration: NetworkService.defaultConfiguration())) {
        self.session = session
    }

    func load<T>(_ resource: Resource<T>) -> Observable<T> {
        guard let request = resource.request else {
            return Observable.error(NetworkError.failedDataLoading)
        }
        return self.session.rx.data(request: request).map(resource.parser).debug("http")
    }

}
