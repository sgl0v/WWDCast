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

    typealias EntityType = [Session]

    static func build(_ json: JSON) throws -> EntityType {
        print(json)
        return try json["contents"].arrayValue.map({ sessionJSON in
            return try SessionBuilder.build(sessionJSON)
        }).filter({ session -> Bool in
            return session.video != nil
        })
    }

}
