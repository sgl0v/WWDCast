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
    static let primaryAttribute = NSStringFromSelector(#selector(getter: id))

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SessionManagedObject> {
        let fetchRequest = NSFetchRequest<SessionManagedObject>(entityName: self.entityName)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
        return fetchRequest
    }

    @NSManaged var id: String?
    @NSManaged var contentId: Int16
    @NSManaged var type: Int16
    @NSManaged var year: Int16
    @NSManaged var track: Int16
    @NSManaged var title: String?
    @NSManaged var summary: String?
    @NSManaged var video: String?
    @NSManaged var captions: String?
    @NSManaged var thumbnail: String?
    @NSManaged var duration: Double
    @NSManaged var favorite: Bool
    @NSManaged var platforms: Int16

}
