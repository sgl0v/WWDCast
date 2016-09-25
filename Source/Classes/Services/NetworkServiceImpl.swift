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
        return self.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet()) ?? ""
    }
}

final class NetworkServiceImpl: NetworkService {

    private let session: NSURLSession

    init(session: NSURLSession = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())) {
        self.session = session
    }
    
    func request(url: NSURL, parameters: [String: AnyObject] = [:]) -> Observable<NSData> {
        let components = NSURLComponents(URL: url, resolvingAgainstBaseURL: false)!
        components.queryItems = parameters.keys.map { NSURLQueryItem(name: $0.URLEscaped, value: "\(parameters[$0])".URLEscaped) }
        return self.session.rx_data(NSURLRequest(URL: components.URL!)).debug("http")
    }

}
