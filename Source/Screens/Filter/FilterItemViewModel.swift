//
//  FilterItemViewModel.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 27/09/2016.
//  Copyright © 2016 Maksym Shcheglov. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

struct FilterItemViewModel: CustomStringConvertible {
    enum Style {
        case checkmark, `switch`
    }

    let title: String
    let selected: Variable<Bool>
    let style: Style

    init(title: String, style: Style = .checkmark, selected: Bool = false) {
        self.title = title
        self.style = style
        self.selected = Variable(selected)
    }

    // MARK: CustomStringConvertible
    var description: String {
        return self.title
    }
}
