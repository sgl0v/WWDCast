//
//  AnyRepository.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 07/06/2017.
//  Copyright © 2017 Maksym Shcheglov. All rights reserved.
//

import Foundation
import RxSwift

/// A type-erased `RepositoryType`.
///
/// Forwards operations to an arbitrary underlying observer with the same `Element` type, hiding the specifics of the underlying repository type.
final class AnyRepository<T>: RepositoryType {
    typealias Element = T

    private let _asObservable: () -> Observable<Element>
    private let _add: (Element) -> Observable<Element>
    private let _update: (Element) -> Observable<Element>
    private let _clean: () -> Observable<Void>

    init<Concrete: RepositoryType>(repository: Concrete) where Concrete.Element == T {
        _asObservable = repository.asObservable
        _add = repository.add
        _update = repository.update
        _clean = repository.clean
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
