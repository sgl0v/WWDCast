//
//  SessionsBuilder.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 05/07/16.
//  Copyright © 2016 Maksym Shcheglov. All rights reserved.
//

import Foundation
import SwiftyJSON

class SessionsBuilder: EntityBuilder {

    typealias EntityType = [Session]

    static func build(_ json: JSON) throws -> EntityType {
        print("\(json["sessions"].arrayValue.count)")
        return try json["sessions"].arrayValue.map() { sessionJSON in
            return try SessionBuilder.build(sessionJSON)
        }
    }

}
