//
//  Logger.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 08/11/2017.
//  Copyright © 2017 Maksym Shcheglov. All rights reserved.
//

import Foundation

/// destination which all others inherit from. do not directly use
protocol LogDestination: class {
    func log(level: Log.Level, message: @autoclosure () -> Any, path: String, function: String, line: Int)
}

/// The `AnyLogDestination` type forwards log method calls to an underlying hashable value
class AnyLogDestination: LogDestination {

    /// The value wrapped by this instance.
    fileprivate var base: LogDestination

    /// Creates a type-erased hashable value that wraps the given instance.
    init(_ base: LogDestination) {
        self.base = base
    }

    func log(level: Log.Level, message: @autoclosure () -> Any, path: String, function: String, line: Int) {
        self.base.log(level: level, message: message, path: path, function: function, line: line)
    }
}

extension AnyLogDestination: Hashable {
    var hashValue: Int {
        return ObjectIdentifier(self.base).hashValue
    }
}

func == (lhs: AnyLogDestination, rhs: AnyLogDestination) -> Bool {
    return ObjectIdentifier(lhs.base) == ObjectIdentifier(rhs.base)
}
