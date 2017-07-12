//
//  EntityRepresentable.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 07/06/2017.
//  Copyright © 2017 Maksym Shcheglov. All rights reserved.
//

import Foundation

protocol EntityRepresentable {
    associatedtype EntityType: CoreDataRepresentable

    func asEntity() -> EntityType
}

extension Sequence where Iterator.Element : EntityRepresentable {

    func asDomainTypes() -> [Iterator.Element.EntityType] {
        return self.map({ record in
            return record.asEntity()
        })
    }
}
