//
//  SessionItemViewModel.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 05/07/16.
//  Copyright © 2016 Maksym Shcheglov. All rights reserved.
//

import Foundation
import RxDataSources

struct SessionItemViewModel {
    var id: String
    var title: String
    var subtitle: String
    var summary: String
    var thumbnailURL: URL
    var thumbnailPlaceholder: UIImage
    var favorite: Bool
}

extension SessionItemViewModel: IdentifiableType {
    typealias Identity = Int

    var identity: Identity {
        return self.hashValue
    }
}

extension SessionItemViewModel: Hashable {
    var hashValue: Int {
        return self.id.hash
    }
}

func == (lhs: SessionItemViewModel, rhs: SessionItemViewModel) -> Bool {
    return lhs.id == rhs.id
}
