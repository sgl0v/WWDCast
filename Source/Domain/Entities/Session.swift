//
//  SessionImpl.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 04/07/16.
//  Copyright © 2016 Maksym Shcheglov. All rights reserved.
//

import Foundation

struct Session {
    let id: String
    let contentId: Int
    let type: EventType
    let year: Year
    let track: Track
    let platforms: Platform
    let title: String
    var subtitle: String {
        let focus = self.platforms.map({ $0.description }).joined(separator: ", ")
        return ["WWDC \(self.year)", "Session \(self.contentId)", focus].joined(separator: " · ")
    }
    let summary: String
    let video: URL?
    let captions: URL?
    let duration: TimeInterval
    let thumbnail: URL
    let favorite: Bool
}

extension Session {
    enum Year: Int {
        case _2013 = 2013, _2014 = 2014, _2015 = 2015, _2016 = 2016, _2017 = 2017

        static let all: [Year] = [._2017, ._2016, ._2015, ._2014, ._2013]
    }

    enum Track: Int {
        case featured, media, developerTools, graphicsAndGames, systemFrameworks, appFrameworks, design, distribution

        init(id: Int) {
            let trackMapping: [Int: Track] = [4: .featured, 1: .media, 5: .developerTools, 8: .graphicsAndGames, 7: .systemFrameworks, 6: .appFrameworks, 9: .design, 3: .distribution]
            guard let track = trackMapping[id] else {
                fatalError("There is no track value for id:\(id)!")
            }
            self = track
        }

        static let all: [Track] = [.featured, .media, .developerTools, .graphicsAndGames, .systemFrameworks, .appFrameworks, .design, .distribution]
    }

    struct Platform: OptionSet {
        let rawValue: Int
        static let iOS = Platform(rawValue: 1 << 0)
        static let macOS = Platform(rawValue: 1 << 1)
        static let tvOS = Platform(rawValue: 1 << 2)
        static let watchOS = Platform(rawValue: 1 << 3)

        static let all: Platform = [.iOS, .macOS, .tvOS, .watchOS]
    }

    enum EventType: Int {
        case session, video, lab, specialEvent, getTogether

        static let all: [EventType] = [.session, .video, .lab, .specialEvent, .getTogether]
    }
}

extension Session: Hashable {

    var hashValue: Int {
        return self.id.hashValue
    }
}

func == (lhs: Session, rhs: Session) -> Bool {
    return lhs.id == rhs.id
}

extension Session: Comparable { }

func < (lhs: Session, rhs: Session) -> Bool {
    if lhs.year.rawValue == rhs.year.rawValue {
        return lhs.id < rhs.id
    }
    return lhs.year.rawValue > rhs.year.rawValue
}

extension Session.Year: CustomStringConvertible {

    var description: String {
        return "\(self.rawValue)"
    }
}

extension Session.Track: Comparable { }

func < (lhs: Session.Track, rhs: Session.Track) -> Bool {
    return lhs.rawValue > rhs.rawValue
}

extension Session.Track: CustomStringConvertible {

    var description: String {
        let mapping: [Session.Track: String] = [.appFrameworks: "App Frameworks", .systemFrameworks: "System Frameworks",
                                                .developerTools: "Developer Tools", .featured: "Featured", .graphicsAndGames: "Graphics and Games",
                                                .design: "Design", .media: "Media", .distribution: "Distribution"]
        let localizationKey = mapping[self] ?? ""
        return NSLocalizedString(localizationKey, comment: "Track description")
    }
}

extension Sequence where Iterator.Element == Session.Track {

    var hashValue: Int {
        let hash = 5381
        return self.reduce(hash, { acc, track in
            return acc ^ track.hashValue
        })
    }

    var description: String {
        let trackDescriptions: [String] = self.map({ track in
            return track.description
        })
        return trackDescriptions.joined(separator: ", ")
    }
}

extension Session.EventType: LosslessStringConvertible {

    init?(_ description: String) {
        let mapping: [String: Session.EventType] = [
            "Session": .session, "Video": .video, "Lab": .lab,
            "Special Event": .specialEvent, "Get-Together": .getTogether]
        guard let value = mapping[description] else {
            assertionFailure("Failed to find a value for track with description '\(description)'!")
            return nil
        }
        self = value
    }

    var description: String {
        let mapping: [Session.EventType: String] = [.session: "Session", .video: "Video", .lab: "Lab",
                                                    .specialEvent: "Special Event", .getTogether: "Get-Together"]
        return NSLocalizedString(mapping[self] ?? "", comment: "Session type")
    }

}

extension Sequence where Iterator.Element == Session.EventType {

    var hashValue: Int {
        let hash = 5381
        return self.reduce(hash, { acc, eventType in
            return acc ^ eventType.hashValue
        })
    }

    var description: String {
        let eventTypeDescriptions: [String] = self.map({ eventType in
            return eventType.description
        })
        return eventTypeDescriptions.joined(separator: ", ")
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
