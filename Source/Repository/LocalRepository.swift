//
//  LocalRepository.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 07/06/2017.
//  Copyright © 2017 Maksym Shcheglov. All rights reserved.
//

import Foundation
import RxSwift
import CoreData

final class LocalRepository<T: NSManagedObject>: NSObject, RepositoryType, NSFetchedResultsControllerDelegate
    where T: EntityRepresentable, T.EntityType.CoreDataType == T {

    typealias Element = [T.EntityType]

    fileprivate let coreDataController: CoreDataController
    fileprivate let allObjectsSubject: PublishSubject<Element>
    fileprivate let frc: NSFetchedResultsController<T>

    init(coreDataController: CoreDataController) {
        self.coreDataController = coreDataController
        self.allObjectsSubject = PublishSubject()

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

    func asObservable() -> Observable<Element> {
        return self.allObjectsSubject.asObservable()
    }

    func add(_ value: Element) -> Observable<Element> {
        let context = self.coreDataController.newBackgroundContext()
        Log.debug("Added \(value.count) records!")
        return value.sync(in: context).flatMap({ items in
            return context.rx.save().flatMap(Observable.just(items.asDomainTypes()))
        })
    }

    func update(_ value: Element) -> Observable<Element> {
        let context = self.coreDataController.newBackgroundContext()
        Log.debug("Updated \(value.count) records!")
        return value.update(in: context).flatMap({ items in
            return context.rx.save().flatMap(Observable.just(items.asDomainTypes()))
        })
    }

    func clean() -> Observable<Void> {
        return Observable.create({[unowned self] observer in
            let context = self.coreDataController.newBackgroundContext()
            let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: T.entityName)
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
            do {
                try context.execute(deleteRequest)
                try context.save()
                observer.onNext(())
            } catch {

                assertionFailure(error.localizedDescription)
                observer.onError(error)
            }
            observer.onCompleted()
            return Disposables.create()
        })
    }

    // MARK: Private

    fileprivate func sendNextElement() {
        self.frc.managedObjectContext.perform {
            let records = self.frc.fetchedObjects ?? []
            Log.debug("Fetched \(records.count) records!")
            self.allObjectsSubject.on(.next(records.asDomainTypes()))
        }
    }

    // MARK: NSFetchedResultsControllerDelegate

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        sendNextElement()
    }

}
