//
//  FilterViewModel.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 14/08/2016.
//  Copyright © 2016 Maksym Shcheglov. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class FilterViewModel {
    var filter: Variable<Filter>

    init() {
        self.filter = Variable(Filter())
    }

    var itemSelected: AnyObserver<FilterDrawable> {
        return AnyObserver {[unowned self] event in
            guard case .Next(let filterItem) = event else {
                return
            }
            
        }
    }

}
