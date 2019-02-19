//
//  ConsoleDestination.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 09/11/2017.
//  Copyright © 2017 Maksym Shcheglov. All rights reserved.
//

import Foundation
import os

class ConsoleDestination: LogDestination {

    private let level: Log.Level
    private let queue: DispatchQueue // serial queue to async output
    private let log: OSLog
    private let identifier = "\(String(describing: Bundle.main.bundleIdentifier)).logger"

    init(_ level: Log.Level = .verbose) {
        self.level = level
        self.queue = DispatchQueue(label: identifier, qos: .utility)
        self.log = OSLog(subsystem: identifier, category: "application")
    }

    func log(level: Log.Level, message: @autoclosure () -> Any, path: String, function: String, line: Int) {
        guard isLogging(level) else {
            return
        }
        let formattedMessage = "[\(getFile(path)):\(line) \(function)] \(message())"
        self.queue.async {
            os_log("%@", log: self.log, type: self.osLogType(from: level), formattedMessage)
        }
    }

    private func osLogType(from logLevel: Log.Level) -> OSLogType {
        switch logLevel {
        case .debug:
            return .debug
        case .info:
            return .info
        case .verbose:
            return .default
        case .warning:
            return .fault
        case .error:
            return .error
        }
    }

    private func isLogging(_ level: Log.Level) -> Bool {
        return level.rawValue >= self.level.rawValue
    }

    private func getFile(_ path: String) -> String {
        guard let range = path.range(of: "/", options: .backwards) else {
            return path
        }

        return String(path[range.upperBound...])
    }
}
