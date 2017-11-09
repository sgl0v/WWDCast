//
//  RxExtensions.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 05/07/16.
//  Copyright © 2016 Maksym Shcheglov. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

// One way binding operator

infix operator <->

infix operator <~

infix operator ~>

// Two way binding operator between control property and variable, that's all it takes {

func <-> <T>(property: ControlProperty<T>, variable: Variable<T>) -> Disposable {
    let bindToUIDisposable = variable.asObservable()
        .bind(to: property)
    let bindToVariable = property
        .subscribe(onNext: { value in
            variable.value = value
            },
                   onCompleted: {
                    bindToUIDisposable.dispose()
        })

    return Disposables.create(bindToUIDisposable, bindToVariable)
}

protocol Optionable {
    associatedtype WrappedType
    func toOptional() -> WrappedType?
}

extension Optional: Optionable {
    typealias WrappedType = Wrapped

    // just to cast `Optional<Wrapped>` to `Wrapped?`
    func toOptional() -> WrappedType? {
        return self
    }
}

extension ObservableType where E: Optionable {

    /// Unwraps optional elements of an observable sequence.
    ///
    /// - Returns: An observable sequence of unwrapped elements
    func unwrap() -> Observable<E.WrappedType> {
        return self.map({ element in
            guard let element = element.toOptional() else {
                fatalError("Failed to unwrap the optional value!")
            }
            return element
        })
    }

    func rejectNil() -> Observable<E> {
        return self.filter({ value in
            return value.toOptional() != nil
        })
    }
}

extension ObservableType {

    func mapToVoid() -> Observable<Void> {
        return map { _ in }
    }

    func flatMap<T>(_ observable: Observable<T>) -> Observable<T> {
        return self.flatMap { _ in
            return observable
        }
    }
}

extension Observable where Element : Sequence, Element.Iterator.Element : Comparable {

    /// Sorts each element of an observable sequence. 
    ///
    /// - Returns: An observable sequence of sorted elements
    func sort() -> Observable<[Element.Iterator.Element]> {
        return self.map({ sequence in
            return sequence.sorted()
        })
    }
}
