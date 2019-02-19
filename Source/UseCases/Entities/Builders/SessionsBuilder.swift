//
//  SessionsBuilder.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 05/07/16.
//  Copyright © 2016 Maksym Shcheglov. All rights reserved.
//

import Foundation
import SwiftyJSON

class SessionsBuilder: EntityBuilderType {

    typealias Input = Data
    typealias EntityType = [Session]

    static func build(from data: Data) throws -> EntityType {
        let json = try JSON(data: data)
        Log.verbose(json)
        return try json["contents"].arrayValue.filter({ sessionJSON in
            let media = sessionJSON["media"]
            let videoUrl = media["tvOShls"].string ?? media["downloadHD"].string
            return videoUrl != nil
        }).map({ json in
            return try SessionBuilder.build(from: json)
        })
    }

}
