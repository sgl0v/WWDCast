//
//  SessionManagedObject+CoreDataProperties.swift
//  
//
//  Created by Maksym Shcheglov on 22/05/2017.
//
//

import Foundation
import CoreData

extension SessionManagedObject: CoreDataPersistable {

    static let entityName = "\(SessionManagedObject.self)"
    static let primaryAttribute = NSStringFromSelector(#selector(getter: uniqueId))

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SessionManagedObject> {
        let fetchRequest = NSFetchRequest<SessionManagedObject>(entityName: self.entityName)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "uniqueId", ascending: true)]
        return fetchRequest
    }

    @NSManaged public var uniqueId: String?
    @NSManaged public var id: Int16
    @NSManaged public var year: Int16
    @NSManaged public var track: Int16
    @NSManaged public var title: String?
    @NSManaged public var summary: String?
    @NSManaged public var video: String?
    @NSManaged public var captions: String?
    @NSManaged public var thumbnail: String?
    @NSManaged public var favorite: Bool
    @NSManaged public var platforms: String?

}

