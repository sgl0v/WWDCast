//
//  CoreDataSource.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 07/06/2017.
//  Copyright © 2017 Maksym Shcheglov. All rights reserved.
//

import Foundation
import RxSwift
import CoreData

final class CoreDataSource<T: NSManagedObject>: NSObject, DataSourceType, NSFetchedResultsControllerDelegate where T:  EntityRepresentable, T.EntityType.CoreDataType == T {

    typealias Item = T.EntityType

    enum Error: Swift.Error {
        case itemNotFound
    }

    fileprivate let coreDataController: CoreDataController
    fileprivate let allObjectsSubject: PublishSubject<[Item]>
    fileprivate let frc: NSFetchedResultsController<T>

    init(coreDataController: CoreDataController) {
        self.coreDataController = coreDataController
        self.allObjectsSubject = PublishSubject<[Item]>()

        self.frc = NSFetchedResultsController(fetchRequest: T.fetchRequest(),
                                              managedObjectContext: self.coreDataController.viewContext,
                                              sectionNameKeyPath: nil,
                                              cacheName: nil)
        super.init()
        self.frc.delegate = self
        do {
            try self.frc.performFetch()
            sendNextElement()
        } catch {
            self.allObjectsSubject.on(.error(error))
        }
    }

    func allObjects() -> Observable<[Item]> {
        return self.allObjectsSubject.asObservable()
    }

    func get(byId id: String) -> Observable<Item> {
        return self.allObjects().flatMap({ items -> Observable<Item> in
            let item = items.filter({ item in
                return item.uid == id
            }).first
            if let item = item {
                return Observable.just(item)
            }
            return Observable.error(Error.itemNotFound)
        })
    }

    func add(_ items: [Item]) -> Observable<[Item]> {
        let context = self.coreDataController.newBackgroundContext()
        return items.sync(in: context).flatMap({ items in
            return context.rx.save().flatMap(Observable.just(items.asDomainTypes()))
        })
    }

    func update(_ items: [Item]) -> Observable<[Item]> {
        let context = self.coreDataController.newBackgroundContext()
        return items.update(in: context).flatMap({ items in
            return context.rx.save().flatMap(Observable.just(items.asDomainTypes()))
        })
    }

    func clean() -> Observable<Void> {
        return Observable.create({[weak self] observer in
            guard let strongSelf = self else {
                assertionFailure("The \(CoreDataSource.self) object is deallocated!")
                return Disposables.create()
            }
            let context = strongSelf.coreDataController.newBackgroundContext()
            let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: T.entityName)
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
            do {
                try context.execute(deleteRequest)
                try context.save()
                observer.onNext()
            } catch {
                assertionFailure(error.localizedDescription)
                observer.onError(error)
            }
            observer.onCompleted()
            return Disposables.create()
        })
    }

    func delete(byId id: String) -> Observable<Void> {
        let bgContext = self.coreDataController.newBackgroundContext()
        let item: Observable<T?> = bgContext.rx.first(with: id)
        return item.rejectNil().unwrap().map(bgContext.delete).flatMap(bgContext.rx.save)
    }

    // MARK: Private

    fileprivate func sendNextElement() {
        self.frc.managedObjectContext.perform {
            NSLog("Fetched \(self.frc.fetchedObjects?.count) records!")
            guard let records = self.frc.fetchedObjects else {
                return
            }
            self.allObjectsSubject.on(.next(records.asDomainTypes()))
        }
    }

    // MARK: NSFetchedResultsControllerDelegate

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        sendNextElement()
    }

}
