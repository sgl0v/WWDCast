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

    func GET(URLString: String, parameters: [String: AnyObject] = [:]) -> Observable<NSData> {
        let query = parameters.keys.map( { "\($0)=\(parameters[$0])" }).joinWithSeparator("&")
        let escapedQuery = query.URLEscaped
        let urlContent = "\(URLString)?\(escapedQuery)"
        let url = NSURL(string: urlContent)!

        return self.session.rx_data(NSURLRequest(URL: url))
    }

}
