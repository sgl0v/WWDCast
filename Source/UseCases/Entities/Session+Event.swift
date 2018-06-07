//
//  Session+Event.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 05/06/2018.
//  Copyright © 2018 Maksym Shcheglov. All rights reserved.
//

import Foundation

extension Session {
    enum EventType: Int {
        case session, video, lab, specialEvent, getTogether

        static let all: [EventType] = [.session, .video, .lab, .specialEvent, .getTogether]
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
