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
class Repository<Element> {

    private let _value: Variable<Element>

    /// Gets or sets current value of variable.
    ///
    /// Whenever a new value is set, all the observers are notified of the change.
    ///
    /// Even if the newly set value is same as the old value, observers are still notified for change.
    public var value: Element {
        get {
            return self._value.value
        }
        set(newValue) {
            self._value.value = newValue
        }
    }

    /// Initializes variable with initial value.
    ///
    /// - parameter value: Initial variable value.
    init(value: Element) {
        self._value = Variable(value)
    }

    public func asObservable() -> Observable<Element> {
        return self._value.asObservable()
    }

}
