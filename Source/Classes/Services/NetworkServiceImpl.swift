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

    func GET<Builder: EntityBuilder>(url: NSURL, parameters: [String: AnyObject] = [:], builder: Builder.Type) -> Observable<Builder.EntityType> {
        let components = NSURLComponents(URL: url, resolvingAgainstBaseURL: false)!
        components.queryItems = parameters.keys.map { NSURLQueryItem(name: $0, value: "\(parameters[$0])") }
        return self.session.rx_data(NSURLRequest(URL: components.URL!))
            .map({ data in builder.build(JSON(data: data)) })
            .debug("http")
    }

}
