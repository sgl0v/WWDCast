//
//  AnyDataSource.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 07/06/2017.
//  Copyright © 2017 Maksym Shcheglov. All rights reserved.
//

import Foundation
import RxSwift

/// A type-erased `DataSourceType`.
///
/// Forwards operations to an arbitrary underlying observer with the same `Item` type, hiding the specifics of the underlying data source type.
final class AnyDataSource<T>: DataSourceType {
    typealias Item = T

    private let _allObjects: () -> Observable<[Item]>
    private let _get: (String) -> Observable<Item>
    private let _add: ([Item]) -> Observable<[Item]>
    private let _update: ([Item]) -> Observable<[Item]>
    private let _clean: () -> Observable<Void>
    private let _delete: (String) -> Observable<Void>

    init<Concrete: DataSourceType>(dataSource: Concrete) where Concrete.Item == T {
        _allObjects = dataSource.allObjects
        _get = dataSource.get
        _add = dataSource.add
        _update = dataSource.update
        _clean = dataSource.clean
        _delete = dataSource.delete
    }

    func allObjects() -> Observable<[Item]> {
        return _allObjects()
    }

    func get(byId id: String) -> Observable<Item> {
        return _get(id)
    }

    func add(_ items: [Item]) -> Observable<[Item]> {
        return _add(items)
    }

    func update(_ items: [Item]) -> Observable<[Item]> {
        return _update(items)
    }

    func clean() -> Observable<Void> {
        return _clean()
    }

    func delete(byId id: String) -> Observable<Void> {
        return _delete(id)
    }
    
}
