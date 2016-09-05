//
//  SessionViewModels.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 10/07/16.
//  Copyright © 2016 Maksym Shcheglov. All rights reserved.
//

import Foundation
import RxDataSources

struct SessionViewModels: SectionModelType, CustomStringConvertible {
    let title: String
    let items: [SessionViewModel]

    init(title: String, items: [SessionViewModel]) {
        self.title = title
        self.items = items
    }

    // MARK: SectionModelType

    typealias Item = SessionViewModel

    init(original: SessionViewModels, items: [Item]) {
        self.title = original.title
        self.items = items
    }

    // MARK: CustomStringConvertible
    var description : String {
        return self.title
    }

}

extension SessionViewModels: Hashable {
    var hashValue: Int {
        return self.title.hash
    }
}

func == (lhs: SessionViewModels, rhs: SessionViewModels) -> Bool {
    return lhs.title == rhs.title && lhs.items == rhs.items
}
