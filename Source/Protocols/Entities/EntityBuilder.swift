//
//  EntityBuilder.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 04/07/16.
//  Copyright © 2016 Maksym Shcheglov. All rights reserved.
//

import Foundation
import SwiftyJSON

protocol EntityBuilder {

    associatedtype EntityType

    static func build(json: JSON) -> EntityType
    
}
