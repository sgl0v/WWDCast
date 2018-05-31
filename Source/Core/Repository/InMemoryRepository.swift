//
//  Repository.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 31/01/2018.
//  Copyright © 2018 Maksym Shcheglov. All rights reserved.
//

import Foundation
import RxSwift

/// In-memory repository.
class InMemoryRepository<T: Equatable>: RepositoryType {

    typealias Element = T

    private let value: BehaviorSubject<Element>

    /// Initializes repository with initial value.
    ///
    /// - parameter value: Initial variable value.
    init(value: Element) {
        self.value = BehaviorSubject(value: value)
    }

    func asObservable() -> Observable<Element> {
        return self.value.asObservable().distinctUntilChanged()
    }

    func add(_ element: T) -> Observable<T> {
        self.value.on(.next(element))
        return self.asObservable()
    }

    func update(_ element: T) -> Observable<T> {
        self.value.on(.next(element))
        return self.asObservable()
    }

    func clean() -> Observable<Void> {
        return .just(())
    }
}
