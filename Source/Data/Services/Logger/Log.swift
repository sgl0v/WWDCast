//
//  Log.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 09/11/2017.
//  Copyright © 2017 Maksym Shcheglov. All rights reserved.
//

import Foundation

public class Log {

    // a set of active destinations
    private(set) static var destinations = Set<AnyLogDestination>()

    public enum Level: Int {
        case verbose = 0
        case debug = 1
        case info = 2
        case warning = 3
        case error = 4
    }

    /// Adds specified log destination
    @discardableResult
    class func addDestination(_ destination: LogDestination) -> Bool {
        let destination = AnyLogDestination(destination)
        if destinations.contains(destination) {
            return false
        }
        destinations.insert(destination)
        return true
    }

    /// Removes specified log destination
    @discardableResult
    class func removeDestination(_ destination: LogDestination) -> Bool {
        let destination = AnyLogDestination(destination)
        if destinations.contains(destination) == false {
            return false
        }
        destinations.remove(destination)
        return true
    }

    /// Removes all log destinations
    static func removeAllDestinations() {
        destinations.removeAll()
    }

    // MARK: Levels

    /// log something generally unimportant (lowest priority)
    static func verbose(_ message: @autoclosure () -> Any, _ path: String = #file, _ function: String = #function, line: Int = #line) {
        log(level: .verbose, message: message, path: path, function: function, line: line)
    }

    /// log debug messages (low priority)
    static func debug(_ message: @autoclosure () -> Any, _ path: String = #file, _ function: String = #function, line: Int = #line) {
        log(level: .debug, message: message, path: path, function: function, line: line)
    }

    /// log a message with a normal priority (not an issue or error)
    static func info(_ message: @autoclosure () -> Any, _ path: String = #file, _ function: String = #function, line: Int = #line) {
        log(level: .info, message: message, path: path, function: function, line: line)
    }

    /// log a warning which may cause big trouble soon (high priority)
    static func warning(_ message: @autoclosure () -> Any, _ path: String = #file, _ function: String = #function, line: Int = #line) {
        log(level: .warning, message: message, path: path, function: function, line: line)
    }

    /// log an error (highest priority)
    static func error(_ message: @autoclosure () -> Any, _ path: String = #file, _ function: String = #function, line: Int = #line) {
        log(level: .error, message: message, path: path, function: function, line: line)
    }

    /// internal helper function to log the message
    private static func log(level: Level, message: @autoclosure () -> Any, path: String, function: String, line: Int) {
        for destination in self.destinations {
            destination.log(level: level, message: message, path: path, function: function, line: line)
        }
    }
}
