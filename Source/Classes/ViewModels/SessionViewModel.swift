//
//  SessionViewModel.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 05/07/16.
//  Copyright © 2016 Maksym Shcheglov. All rights reserved.
//

import Foundation
import RxDataSources

struct SessionViewModel {
    var title: String
    var summary: String
    var thumbnailURL: NSURL
}

extension SessionViewModel: IdentifiableType {
    typealias Identity = Int

    var identity : Identity {
        return self.hashValue
    }
}

extension SessionViewModel: Hashable {
    var hashValue: Int {
        return self.title.hash ^ self.summary.hash ^ self.thumbnailURL.hash
    }
}

func == (lhs: SessionViewModel, rhs: SessionViewModel) -> Bool {
    return lhs.title == rhs.title && lhs.summary == rhs.summary && lhs.thumbnailURL == rhs.thumbnailURL
}
