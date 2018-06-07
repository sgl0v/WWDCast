//
//  Session+Platform.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 05/06/2018.
//  Copyright © 2018 Maksym Shcheglov. All rights reserved.
//

import Foundation

extension Session {

    struct Platform: OptionSet {
        let rawValue: Int
        static let iOS = Platform(rawValue: 1 << 0)
        static let macOS = Platform(rawValue: 1 << 1)
        static let tvOS = Platform(rawValue: 1 << 2)
        static let watchOS = Platform(rawValue: 1 << 3)

        static let all: Platform = [.iOS, .macOS, .tvOS, .watchOS]
    }
}

extension Session.Platform: Hashable {

    var hashValue: Int {
        return self.rawValue.hashValue
    }
}

extension Session.Platform: LosslessStringConvertible {

    init?(_ description: String) {
        let mapping: [String: Session.Platform] = [
            "iOS": .iOS, "macOS": .macOS, "tvOS": .tvOS,
            "watchOS": .watchOS]
        guard let value = mapping[description] else {
            assertionFailure("Failed to find a value for track with description '\(description)'!")
            return nil
        }
        self = value
    }

    var description: String {
        let mapping: [Session.Platform: String] = [.iOS: "iOS", .macOS: "macOS", .tvOS: "tvOS",
                                                   .watchOS: "watchOS"]
        return self.map ({ value in
            return NSLocalizedString(mapping[value] ?? "", comment: "Platform description")
        }).joined(separator: ", ")
    }
}

extension Session.Platform: Sequence {

    func makeIterator() -> AnyIterator<Session.Platform> {
        var remainingBits = rawValue
        var bitMask: RawValue = 1
        return AnyIterator {
            while remainingBits != 0 {
                defer { bitMask = bitMask &* 2 }
                if remainingBits & bitMask != 0 {
                    remainingBits = remainingBits & ~bitMask
                    return Session.Platform(rawValue: bitMask)
                }
            }
            return nil
        }
    }
}
