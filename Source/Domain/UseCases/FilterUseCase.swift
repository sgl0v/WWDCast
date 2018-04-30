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

    var filterObservable: Observable<Filter> { get }

    /// Updates filter with the specified value
    ///
    /// - Parameter filter: the new filter value
    /// - Returns: The filter observable.
    func update(_ filter: Filter) -> Observable<Filter>

    /// Saves the current filter value to the repository
    ///
    /// - Returns: The filter observable.
    func save() -> Observable<Filter>
}

class FilterUseCase: FilterUseCaseType {

    private let repository: AnyDataSource<Filter>
    private let value: PublishSubject<Filter>

    lazy var filterObservable: Observable<Filter> = {
        return Observable.merge(self.repository.asObservable(), self.value.asObservable()).share(replay: 1)
    }()

    init(repository: AnyDataSource<Filter>) {
        self.repository = repository
        self.value = PublishSubject<Filter>()
    }

    func update(_ filter: Filter) -> Observable<Filter> {
        self.value.on(.next(filter))
        return self.filterObservable
    }

    func save() -> Observable<Filter> {
        return self.filterObservable.take(1).flatMap({ filter in
            return self.repository.update(filter)
        })
    }

}
