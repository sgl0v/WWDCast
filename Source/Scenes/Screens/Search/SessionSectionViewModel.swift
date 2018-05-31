//
//  SessionSectionViewModel.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 10/07/16.
//  Copyright © 2016 Maksym Shcheglov. All rights reserved.
//

import Foundation
import RxDataSources

struct SessionSectionViewModel: SectionModelType, CustomStringConvertible {
    let title: String
    let items: [SessionItemViewModel]

    init(title: String, items: [SessionItemViewModel]) {
        self.title = title
        self.items = items
    }

    // MARK: SectionModelType

    typealias Item = SessionItemViewModel

    init(original: SessionSectionViewModel, items: [Item]) {
        self.title = original.title
        self.items = items
    }

    // MARK: CustomStringConvertible
    var description: String {
        return self.title
    }

}

extension SessionSectionViewModel: Hashable {
    var hashValue: Int {
        return self.title.hash
    }
}

func == (lhs: SessionSectionViewModel, rhs: SessionSectionViewModel) -> Bool {
    return lhs.title == rhs.title && lhs.items == rhs.items
}
