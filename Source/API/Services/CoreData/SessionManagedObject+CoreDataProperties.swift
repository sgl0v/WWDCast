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

    @NSManaged var uniqueId: String?
    @NSManaged var id: Int16
    @NSManaged var year: Int16
    @NSManaged var track: Int16
    @NSManaged var title: String?
    @NSManaged var summary: String?
    @NSManaged var video: String?
    @NSManaged var captions: String?
    @NSManaged var thumbnail: String?
    @NSManaged var favorite: Bool
    @NSManaged var platforms: Int16

}
