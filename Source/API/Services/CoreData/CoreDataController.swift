//
//  CoreDataController.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 22/05/2017.
//  Copyright © 2017 Maksym Shcheglov. All rights reserved.
//

import Foundation
import CoreData
import RxSwift

final class CoreDataController {

    private var persistentContainer: NSPersistentContainer!

    var viewContext: NSManagedObjectContext {
        return self.persistentContainer.viewContext
    }

    init(name: String) {
        self.persistentContainer = NSPersistentContainer(name: name)
        self.persistentContainer.loadPersistentStores { _, error in
            if let coreDataError = error {
                assertionFailure(coreDataError.localizedDescription)
                Log.error(coreDataError)
                return
            }
            self.persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
            try? self.persistentContainer.viewContext.setQueryGenerationFrom(.current)
        }
    }

    func newBackgroundContext() -> NSManagedObjectContext {
        return self.persistentContainer.newBackgroundContext()
    }

    /// Executes a block on the main queue
    ///
    /// - Parameter block: A block to execute on the main queue
    func perform(_ block: @escaping (NSManagedObjectContext) -> Void) {
        self.viewContext.perform {
            block(self.viewContext)
        }
    }

    /// Synchronously performs a given block on the main queue
    ///
    /// - Parameter block: A block to execute on the main queue
    func performAndWait(_ block: @escaping (NSManagedObjectContext) -> Void) {
        self.viewContext.performAndWait {
            block(self.viewContext)
        }
    }

    /// Executes a block on a new private queue context.
    ///
    /// - Parameter block: A block to execute on a newly created private queue context
    func performInBackground(_ block: @escaping (NSManagedObjectContext) -> Void) {
        return self.persistentContainer.performBackgroundTask(block)
    }

}
