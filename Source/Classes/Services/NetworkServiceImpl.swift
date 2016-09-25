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

extension String {
    var URLEscaped: String {
        return self.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet()) ?? ""
    }
}

final class NetworkServiceImpl: NetworkService {

    private let session: NSURLSession

    init(session: NSURLSession = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())) {
        self.session = session
    }

    func request<Builder: EntityBuilder>(url: NSURL, parameters: [String: AnyObject] = [:], builder: Builder.Type) -> Observable<Builder.EntityType> {
        let components = NSURLComponents(URL: url, resolvingAgainstBaseURL: false)!
        components.queryItems = parameters.keys.map { NSURLQueryItem(name: $0.URLEscaped, value: "\(parameters[$0])".URLEscaped) }
        return self.session.rx_data(NSURLRequest(URL: components.URL!))
            .flatMap(build(builder))
            .debug("http")
    }
    
    private func build<Builder: EntityBuilder>(builder: Builder.Type) -> NSData -> Observable<Builder.EntityType> {
        return { data in
            do {
                let entity = try builder.build(JSON(data: data))
                return Observable.just(entity)
            } catch let error {
                return Observable.error(error)
            }
        }
    }

}
