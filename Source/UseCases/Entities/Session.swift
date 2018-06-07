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
    let video: URL
    let captions: URL?
    let duration: TimeInterval
    let thumbnail: URL
    let favorite: Bool
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
