//
//  SessionImpl.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 04/07/16.
//  Copyright © 2016 Maksym Shcheglov. All rights reserved.
//

import Foundation

struct SessionImpl: Session {
    var uniqueId: String { return "#\(year)-\(id)" }
    let id: Int
    let year: Int
    let track: Track
    let focus: [Focus]
    let title: String
    var subtitle: String {
        let focusString = self.focus.map({ $0.rawValue }).joinWithSeparator(", ")
        return "WWDC \(year) - Session \(id) - \(focusString)"
    }
    let summary: String
    let videoURL: NSURL
    let hdVideoURL: NSURL
    let shelfImageURL: NSURL
}

extension SessionImpl: Hashable {

    var hashValue: Int {
        return self.uniqueId.hashValue
    }
}

func ==(lhs: SessionImpl, rhs: SessionImpl) -> Bool {
    return lhs.uniqueId == rhs.uniqueId
}
