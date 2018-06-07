//
//  CoreDataRepresentable.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 07/06/2017.
//  Copyright © 2017 Maksym Shcheglov. All rights reserved.
//

import Foundation
import RxSwift
import CoreData

protocol CoreDataRepresentable {
    associatedtype CoreDataType: CoreDataPersistable

    var uid: String {get}

    func update(object: CoreDataType)
}

extension CoreDataRepresentable where Self.CoreDataType: NSManagedObject {

    func sync(in context: NSManagedObjectContext) -> Observable<CoreDataType> {
        return context.rx.sync(entity: self, update: update)
    }

    func update(in context: NSManagedObjectContext) -> Observable<CoreDataType> {
        return context.rx.update(entity: self, update: update)
    }
}

extension Sequence where Iterator.Element: CoreDataRepresentable, Iterator.Element.CoreDataType: NSManagedObject {

    typealias CoreDataType = Iterator.Element.CoreDataType

    func sync(in context: NSManagedObjectContext) -> Observable<[CoreDataType]> {
        return Observable.merge(self.map { element in
            element.sync(in: context)
        }).toArray()
    }

    func update(in context: NSManagedObjectContext) -> Observable<[CoreDataType]> {
        return Observable.merge(self.map { element in
            element.update(in: context)
        }).toArray()
    }
}
