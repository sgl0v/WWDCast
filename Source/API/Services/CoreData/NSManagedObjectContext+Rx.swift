//
//  NSManagedObjectContext+Rx.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 23/05/2017.
//  Copyright © 2017 Maksym Shcheglov. All rights reserved.
//

import Foundation
import CoreData
import RxSwift

extension Reactive where Base: NSManagedObjectContext {

    func fetch<T: CoreDataPersistable>(_ fetchRequest: NSFetchRequest<T>) -> Observable<[T]> where T: NSManagedObject {
        do {
            let sessions = try self.base.fetch(fetchRequest)
            return Observable.just(sessions)
        } catch {
            assertionFailure("Failed to fetch objects from core data: \(error)")
            return Observable.error(error)
        }
    }

    func save() -> Observable<Void> {
        return Observable.deferred {
            if !self.base.hasChanges {
                return Observable.just()
            }

            do {
                try self.base.save()
            } catch {
                assertionFailure("Failed to save the context with error: \(error)")
                return Observable.error(error)
            }
            return Observable.just()
        }
    }

    func first<T: CoreDataPersistable>(with id: String) -> Observable<T?> where T: NSManagedObject {
        let entityName = String(describing: T.self)
        let request = NSFetchRequest<T>(entityName: entityName)
        request.predicate = NSPredicate(format: "(\(T.primaryAttribute) = %@)", id)
        return self.fetch(request).map({ managedObjects -> T? in
            return managedObjects.first
        })
    }

    func sync<T: CoreDataRepresentable, U: NSManagedObject>(entity: T,
                                                            update: @escaping (U) -> Void) -> Observable<U> where T.CoreDataType == U {
        return self.first(with: entity.uid).flatMap({ (obj: U?) -> Observable<U>  in
            if let record = obj {
                return Observable.just(record)
            }
            let record = U(context: self.base)
            update(record)
            return Observable.just(record)
        })
    }

    func update<T: CoreDataRepresentable, U: NSManagedObject>(entity: T,
                                                              update: @escaping (U) -> Void) -> Observable<U> where T.CoreDataType == U {
        return self.first(with: entity.uid).flatMap({ (obj: U?) -> Observable<U>  in
            if let record = obj {
                update(record)
                return Observable.just(record)
            }
            return Observable.empty()
        })
    }
}
