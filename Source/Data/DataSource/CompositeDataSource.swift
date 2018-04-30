//
//  CompositeDataSource.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 07/06/2017.
//  Copyright © 2017 Maksym Shcheglov. All rights reserved.
//

import Foundation
import RxSwift

final class CompositeDataSource<T>: DataSourceType {

    typealias Element = T

    private let networkDataSource: AnyDataSource<T>
    private let coreDataSource: AnyDataSource<T>

    init(networkDataSource: AnyDataSource<T>, coreDataSource: AnyDataSource<T>) {
        self.networkDataSource = networkDataSource
        self.coreDataSource = coreDataSource
    }

    func asObservable() -> Observable<Element> {
        return self._allObjects
    }

    lazy var _allObjects: Observable<Element> = {
        let cachedObjects = self.coreDataSource.asObservable()
        let loadedObjects = self.networkDataSource.asObservable().flatMap(self.coreDataSource.add)
        return Observable.of(cachedObjects, loadedObjects)
            .merge()
            .share(replay: 1)
    }()

    func add(_ value: Element) -> Observable<Element> {
        return self.networkDataSource.add(value).concat(self.coreDataSource.add(value))
    }

    func update(_ value: Element) -> Observable<Element> {
        return self.networkDataSource.update(value).concat(self.coreDataSource.update(value))
    }

    func clean() -> Observable<Void> {
        return self.networkDataSource.clean().concat(self.coreDataSource.clean())
    }

}
