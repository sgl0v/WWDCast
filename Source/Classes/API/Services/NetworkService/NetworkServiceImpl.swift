//
//  NetworkServiceImpl.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 09/07/16.
//  Copyright © 2016 Maksym Shcheglov. All rights reserved.
//

import Foundation
import RxSwift
import SwiftyJSON

final class NetworkServiceImpl: NetworkService {

    private let session: URLSession
    private static func defaultConfiguration() -> URLSessionConfiguration {
        let configuration = URLSessionConfiguration.default
        configuration.allowsCellularAccess = false
        return configuration
    }
    
    init(session: URLSession = URLSession(configuration: NetworkServiceImpl.defaultConfiguration())) {
        self.session = session
    }
    
    func load<T>(_ resource: Resource<T>) -> Observable<T> {
        return self.session.rx.data(request: resource.request).map({ JSON(data: $0) }).map(resource.parser).debug("http")
    }

}
