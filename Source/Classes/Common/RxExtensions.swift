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
        .bindTo(property)
    let bindToVariable = property
        .subscribe(onNext: { n in
            variable.value = n
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
    
    func unwrap() -> Observable<E.WrappedType> {
        return self.map({ $0.toOptional()! })
    }
    
    func rejectNil() -> Observable<E> {
        return self.filter({ value in
            return value.toOptional() != nil
        })
    }
}

extension Observable where Element : Sequence, Element.Iterator.Element : Comparable {
    
    public func sort() -> Observable<[Element.Iterator.Element]> {
        return self.map({ sequence in
            return sequence.sorted()
        })
    }
}
