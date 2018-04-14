//
//  Resource.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 29/11/2016.
//  Copyright © 2016 Maksym Shcheglov. All rights reserved.
//

import Foundation
import SwiftyJSON

extension String {
    var URLEscaped: String {
        return self.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? ""
    }
}

struct Resource<T> {

    typealias Parser = (Data) throws -> T
    let url: URL
    let parameters: [String: AnyObject]
    let parser: Parser
    var request: URLRequest? {
        guard var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            return nil
        }
        components.queryItems = parameters.keys.map { key in
            URLQueryItem(name: key.URLEscaped, value: "\(String(describing: parameters[key]))".URLEscaped)
        }
        guard let url = components.url else {
            return nil
        }
        return URLRequest(url: url)
    }

    init(url: URL, parameters: [String: AnyObject] = [:], parser: @escaping Parser) {
        self.url = url
        self.parameters = parameters
        self.parser = parser
    }
}

extension Resource where T == Data {

    init(url: URL) {
        self.init(url: url, parser: { $0 })
    }
}
