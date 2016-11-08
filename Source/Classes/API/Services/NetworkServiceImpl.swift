//
//  NetworkServiceImpl.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 09/07/16.
//  Copyright © 2016 Maksym Shcheglov. All rights reserved.
//

import Foundation
import RxSwift

extension String {
    var URLEscaped: String {
        return self.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? ""
    }
}

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
    
    func request(_ url: URL, parameters: [String: AnyObject] = [:]) -> Observable<Data> {
        guard var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            return Observable.empty()
        }
        components.queryItems = parameters.keys.map { URLQueryItem(name: $0.URLEscaped, value: "\(parameters[$0])".URLEscaped) }
        guard let url = components.url else {
            return Observable.empty()
        }
        return self.session.rx.data(request: URLRequest(url: url)).debug("http")
    }

}
