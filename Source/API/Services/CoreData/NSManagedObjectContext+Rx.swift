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

    func fetch<T: NSFetchRequestResult>(_ fetchRequest: NSFetchRequest<NSFetchRequestResult>) -> Observable<[T]> {
        do {
            if let sessions = try self.base.fetch(fetchRequest) as? [T] {
                return Observable.just(sessions)
            }
            return Observable.just([])
        } catch {
            assertionFailure("Failed to fetch objects from core data: \(error)")
            return Observable.error(error)
        }
    }

    func save() -> Observable<Void> {
        if !self.base.hasChanges {
            return Observable.empty()
        }

        do {
            try self.base.save()
        } catch {
            assertionFailure("Failed to save the context with error: \(error)")
            return Observable.error(error)
        }
        return Observable.just()
    }

    func first<T: NSFetchRequestResult>(with predicate: NSPredicate) -> Observable<T?> {
        return Observable.deferred {
            let entityName = String(describing: T.self)
            let request = NSFetchRequest<T>(entityName: entityName)
            request.predicate = predicate
            do {
                let result = try self.base.fetch(request).first
                return Observable.just(result)
            } catch {
                return Observable.error(error)
            }
        }
    }
}
