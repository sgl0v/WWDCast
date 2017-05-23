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
    associatedtype Item

    func allObjects() -> Observable<[Item]>
    func get(byId id: String) -> Observable<Item?>
    func insert(_ item: Item) -> Observable<Void>
//    func update(_ items: [T])
    func clean() -> Observable<Void>
    func delete(byId id: String) -> Observable<Void>
}

extension Sequence where Iterator.Element : EntityRepresentable {

    func entities() -> [Iterator.Element.EntityType] {
        return self.map({ record in
            return record.asEntity()
        })
    }
}

final class NetworkDataSource<T>: DataSource {
    typealias Item = T


    func allObjects() -> Observable<[Item]> {

    }

    func get(byId id: String) -> Observable<Item?> {

    }

    func insert(_ item: Item) -> Observable<Void> {
        assertionFailure("The function `\(#function)` is not implemented for \(NetworkDataSource.self)!")
        return Observable.empty()
    }

    func clean() -> Observable<Void> {
        assertionFailure("The function `\(#function)` is not implemented for \(NetworkDataSource.self)!")
        return Observable.empty()
    }

    func delete(byId id: String) -> Observable<Void> {
        assertionFailure("The function `\(#function)` is not implemented for \(NetworkDataSource.self)!")
        return Observable.empty()
    }

}

final class CoreDataSource<T: NSManagedObject>: NSObject, DataSource, NSFetchedResultsControllerDelegate where T: CoreDataPersistable & EntityRepresentable {

    typealias Item = T.EntityType

    fileprivate let coreDataController: CoreDataController
    fileprivate let allObjectsSubject: BehaviorSubject<[Item]>
    fileprivate let frc: NSFetchedResultsController<T>

    init(coreDataController: CoreDataController) {
        self.coreDataController = coreDataController
        self.allObjectsSubject = BehaviorSubject(value: [])

        self.frc = NSFetchedResultsController(fetchRequest: T.fetchRequest(),
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

    func allObjects() -> Observable<[Item]> {
        return self.allObjectsSubject.asObservable()
    }

    func get(byId id: String) -> Observable<Item?> {
        let session: Observable<T?> = self.coreDataController.viewContext.rx.first(with: NSPredicate(format: "(id = %@)", id))
        return session.map { $0?.asEntity() }
    }

    func insert(_ item: Item) -> Observable<Void> {
        let bgContext = self.coreDataController.newBackgroundContext()
        let predicate = NSPredicate(format: "(id = %@)", item.uid)
        return bgContext.rx.first(with: predicate).map({ (obj: T?) -> Void  in
            let record = obj ?? T(context: bgContext)
            record.update(item)
        }).flatMap(bgContext.rx.save)
    }

//    func update(_ item: Session) {
//
//    }

    func clean() -> Observable<Void> {
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
        return Observable.empty()
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


//}
//
//extension CoreDataSource: NSFetchedResultsControllerDelegate {

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        sendNextElement()
    }

}
