//
//  EntityBuilder.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 04/07/16.
//  Copyright © 2016 Maksym Shcheglov. All rights reserved.
//

import Foundation
import SwiftyJSON

enum EntityBuilderError: Error {
    case parsingError
}

/// A type that creates model object from the JSON representation
protocol EntityBuilderType {

    associatedtype EntityType

    static func build(_ json: JSON) throws -> EntityType

}
