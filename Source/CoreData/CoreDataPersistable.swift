//
//  CoreDataPersistable.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 07/06/2017.
//  Copyright © 2017 Maksym Shcheglov. All rights reserved.
//

import Foundation
import CoreData

protocol CoreDataPersistable: NSFetchRequestResult {
    static var primaryAttribute: String {get}
    static var entityName: String {get}
    static func fetchRequest() -> NSFetchRequest<Self>
}
