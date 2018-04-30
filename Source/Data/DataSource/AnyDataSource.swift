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
/// Forwards operations to an arbitrary underlying observer with the same `Element` type, hiding the specifics of the underlying data source type.
final class AnyDataSource<T>: DataSourceType {
    typealias Element = T

    private let _asObservable: () -> Observable<Element>
    private let _add: (Element) -> Observable<Element>
    private let _update: (Element) -> Observable<Element>
    private let _clean: () -> Observable<Void>

    init<Concrete: DataSourceType>(dataSource: Concrete) where Concrete.Element == T {
        _asObservable = dataSource.asObservable
        _add = dataSource.add
        _update = dataSource.update
        _clean = dataSource.clean
    }

    func asObservable() -> Observable<Element> {
        return _asObservable()
    }

    func add(_ value: Element) -> Observable<Element> {
        return _add(value)
    }

    func update(_ value: Element) -> Observable<Element> {
        return _update(value)
    }

    func clean() -> Observable<Void> {
        return _clean()
    }

}
