//
//  DataSource.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 23/05/2017.
//  Copyright © 2017 Maksym Shcheglov. All rights reserved.
//

import Foundation
import RxSwift
import CoreData

protocol DataSource: class {
    associatedtype T

    func allObjects() -> Observable<[T]>
    func get(byId id: String) -> Observable<T?>
    func insert(_ item: T) -> Observable<Void>
//    func update(_ items: [T])
    func clean()
    func delete(byId id: String) -> Observable<Void>
}

extension Sequence where Iterator.Element : EntityRepresentable {

    func entities() -> [Iterator.Element.EntityType] {
        return self.map({ record in
            return record.asEntity()
        })
    }
}

final class SessionsCoreDataSource: NSObject, DataSource {

    typealias T = Session

    fileprivate let coreDataController: CoreDataController
    fileprivate let allObjectsSubject: BehaviorSubject<[T]>
    fileprivate let frc: NSFetchedResultsController<SessionManagedObject>

    init(coreDataController: CoreDataController) {
        self.coreDataController = coreDataController
        self.allObjectsSubject = BehaviorSubject(value: [])

        self.frc = NSFetchedResultsController(fetchRequest: SessionManagedObject.fetchRequest(),
                                              managedObjectContext: self.coreDataController.viewContext,
                                              sectionNameKeyPath: nil,
                                              cacheName: nil)
        super.init()
        self.frc.delegate = self
        do {
            try self.frc.performFetch()
        } catch let e {
            self.allObjectsSubject.on(.error(e))
        }
    }

    func allObjects() -> Observable<[Session]> {
        return self.allObjectsSubject.asObservable()
    }

    func get(byId id: String) -> Observable<Session?> {
        let session: Observable<SessionManagedObject?> = self.coreDataController.viewContext.rx.first(with: NSPredicate(format: "(id = %@)", id))
        return session.map { $0?.asEntity() }
    }

    func insert(_ item: Session) -> Observable<Void> {
        let bgContext = self.coreDataController.newBackgroundContext()
        let predicate = NSPredicate(format: "(id = %@)", item.id)
        return bgContext.rx.first(with: predicate).map({ (obj: SessionManagedObject?) -> Void  in
            let record = obj ?? SessionManagedObject(context: bgContext)
            record.update(item)
        }).flatMap(bgContext.rx.save)
    }

//    func update(_ item: Session) {
//
//    }

    func clean() {
//        let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
//        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
//        do
//        {
//            try context.execute(deleteRequest)
//            try context.save()
//        }
//        catch
//        {
//            print ("There was an error")
//        }
    }

    func delete(byId id: String) -> Observable<Void> {
        let bgContext = self.coreDataController.newBackgroundContext()
        let predicate = NSPredicate(format: "(id = %@)", id)
        return bgContext.rx.first(with: predicate).rejectNil().unwrap().map(bgContext.delete).flatMap(bgContext.rx.save)

//        let predicate = NSPredicate(format: "(id = %@)", id)
//        self.coreDataController.performInBackground { context in
//            context.rx.first(with: predicate).subscribe(onNext: { session in
//                context.delete(session!)
//            })
//        }
    }

    // MARK: Private


    fileprivate func sendNextElement() {
        self.frc.managedObjectContext.perform {
            let records = self.frc.fetchedObjects ?? []
            self.allObjectsSubject.on(.next(records.entities()))
        }
    }


}

extension SessionsCoreDataSource: NSFetchedResultsControllerDelegate {

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        sendNextElement()
    }

}

extension SessionsCoreDataSource: Disposable {

    func dispose() {
        frc.delegate = nil
    }

}
