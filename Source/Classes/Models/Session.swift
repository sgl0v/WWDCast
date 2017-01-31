//
//  SessionImpl.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 04/07/16.
//  Copyright © 2016 Maksym Shcheglov. All rights reserved.
//

import Foundation

struct Session {

    enum Year: Int {
        case _2012 = 2012, _2013 = 2013, _2014 = 2014, _2015 = 2015, _2016 = 2016

        static let all: [Year] = [._2016, ._2015, ._2014, ._2013, ._2012]
    }

    struct Track: OptionSet {
        let rawValue: Int
        static let AppFrameworks = Track(rawValue: 1 << 0)
        static let SystemFrameworks = Track(rawValue: 1 << 1)
        static let DeveloperTools = Track(rawValue: 1 << 2)
        static let Featured = Track(rawValue: 1 << 3)
        static let GraphicsAndGames = Track(rawValue: 1 << 4)
        static let Design = Track(rawValue: 1 << 5)
        static let Media = Track(rawValue: 1 << 6)
        static let Distribution = Track(rawValue: 1 << 7)
        static let all: Track = [.Featured, .Media, .DeveloperTools, .GraphicsAndGames, .SystemFrameworks, .AppFrameworks, .Design, .Distribution]
    }

    enum Platform: String {
        case iOS, macOS, tvOS, watchOS

        static let all: [Platform] = [.iOS, .macOS, .tvOS, .watchOS]

    }

    var uniqueId: String { return "#\(year)-\(id)" }
    let id: Int
    let year: Year
    let track: Track
    let platforms: [Platform]
    let title: String
    var subtitle: String {
        let focus = self.platforms.map({ $0.description }).joined(separator: ", ")
        return ["\(self.year)", "Session \(self.id)", focus].filter({ $0.lengthOfBytes(using: String.Encoding.utf8) > 0}) .joined(separator: " · ")
    }
    let summary: String
    let video: URL?
    let captions: URL?
    let thumbnail: URL
    let favorite: Bool
}

extension Session: Hashable {

    var hashValue: Int {
        return self.uniqueId.hashValue
    }
}

func == (lhs: Session, rhs: Session) -> Bool {
    return lhs.uniqueId == rhs.uniqueId
}

extension Session: Comparable { }

func < (lhs: Session, rhs: Session) -> Bool {
    return lhs.id < rhs.id && lhs.year.rawValue >= rhs.year.rawValue
}

extension Session.Year: CustomStringConvertible {

    var description: String {
        return "WWDC \(self.rawValue)"
    }
}

extension Session.Track: Hashable {

    var hashValue: Int {
        return self.rawValue.hashValue
    }
}

extension Session.Track: CustomStringConvertible {

    var description: String {
        let mapping: [Session.Track: String] = [.AppFrameworks: "App Frameworks", .SystemFrameworks: "System Frameworks", .DeveloperTools: "Developer Tools",
                                        .Featured: "Featured", .GraphicsAndGames: "Graphics and Games", .Design: "Design", .Media: "Media", .Distribution: "Distribution"]
        guard let description = mapping[self] else {
            fatalError("Failed to find description for '\(self)' track!")
        }
        return NSLocalizedString(description, comment: "Track description")
    }
}

extension Session.Platform: CustomStringConvertible {

    var description: String {
        return NSLocalizedString(self.rawValue, comment: "Platform description")
    }
}

extension Session.Track: Sequence {

    func makeIterator() -> AnyIterator<Session.Track> {
        var remainingBits = rawValue
        var bitMask: RawValue = 1
        return AnyIterator {
            while remainingBits != 0 {
                defer { bitMask = bitMask &* 2 }
                if remainingBits & bitMask != 0 {
                    remainingBits = remainingBits & ~bitMask
                    return Session.Track(rawValue: bitMask)
                }
            }
            return nil
        }
    }
}
