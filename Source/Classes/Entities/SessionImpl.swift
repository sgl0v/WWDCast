//
//  SessionImpl.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 04/07/16.
//  Copyright © 2016 Maksym Shcheglov. All rights reserved.
//

import Foundation

struct SessionImpl: Session {
    var uniqueId: String = ""
    var id: Int = 0
    var year: Int = 0
    var date: NSDate? = nil
    var track: String = ""
    var focus: String = ""
    var title: String = ""
    var summary: String = ""
    var videoURL: String = ""
    var hdVideoURL: String = ""
    var slidesURL: String = ""
    var shelfImageURL: String = ""
}

extension SessionImpl: Hashable {

    var hashValue: Int {
        return self.uniqueId.hashValue
    }
}

func ==(lhs: SessionImpl, rhs: SessionImpl) -> Bool {
    return lhs.uniqueId == rhs.uniqueId
}
