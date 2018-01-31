//
//  FilterUseCaseType.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 02/01/2018.
//  Copyright © 2018 Maksym Shcheglov. All rights reserved.
//

import Foundation
import RxSwift

protocol FilterUseCaseType {
    /// The session search filter
    var value: Filter {get set}

    var filterObservable: Observable<Filter> { get }

    /// saves filter to the repo
    func save()
}

class FilterUseCase: FilterUseCaseType {

    private let filterRepository: Repository<Filter>
    private let _value: Variable<Filter>

    public var value: Filter {
        get {
            return self._value.value
        }
        set(newValue) {
            self._value.value = newValue
        }
    }

    public var filterObservable: Observable<Filter> {
        return self._value.asObservable()
    }

    init(filterRepository: Repository<Filter>) {
        self.filterRepository = filterRepository
        self._value = Variable(self.filterRepository.value)
    }

    func save() {
        self.filterRepository.value = self.value
    }

}
