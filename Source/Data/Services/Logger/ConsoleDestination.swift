//
//  ConsoleDestination.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 09/11/2017.
//  Copyright © 2017 Maksym Shcheglov. All rights reserved.
//

import Foundation

class ConsoleDestination: LogDestination {

    private let level: Log.Level
    private let queue: DispatchQueue // serial queue to async output

    init(_ level: Log.Level = .verbose) {
        self.level = level
        self.queue = DispatchQueue(label: "com.sgl0v.wwdcast.logger", qos: .utility)
    }

    func log(level: Log.Level, message: @autoclosure () -> Any, path: String, function: String, line: Int) {
        guard isLogging(level) else {
            return
        }
        let formattedMessage = "[\(level)] [\(getFile(path)):\(line) \(function)] \(message())"
        self.queue.async {
            NSLog("%@", formattedMessage)
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
