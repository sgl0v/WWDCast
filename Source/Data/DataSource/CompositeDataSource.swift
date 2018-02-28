//
//  CompositeDataSource.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 07/06/2017.
//  Copyright © 2017 Maksym Shcheglov. All rights reserved.
//

import Foundation
import RxSwift

final class CompositeDataSource<T: Comparable>: DataSourceType {

    typealias Item = T

    private let networkDataSource: AnyDataSource<T>
    private let coreDataSource: AnyDataSource<T>

    init(networkDataSource: AnyDataSource<T>, coreDataSource: AnyDataSource<T>) {
        self.networkDataSource = networkDataSource
        self.coreDataSource = coreDataSource
    }

    func allObjects() -> Observable<[Item]> {
        return self._allObjects
    }

    lazy var _allObjects: Observable<[Item]> = {
        let cachedObjects = self.coreDataSource.allObjects()
        let loadedObjects = self.networkDataSource.allObjects().flatMap(self.coreDataSource.add)
        return Observable.of(cachedObjects, loadedObjects)
            .merge()
            .sort()
            .subscribeOn(Scheduler.backgroundWorkScheduler)
            .observeOn(Scheduler.mainScheduler)
            .share(replay: 1)
    }()

    func get(byId id: String) -> Observable<T> {
        let cachedObject = self.coreDataSource.get(byId: id)
        let loadedObject = self.networkDataSource.get(byId: id)
        return Observable.of(cachedObject, loadedObject).merge().share(replay: 1)
    }

    func add(_ items: [Item]) -> Observable<[Item]> {
        return self.networkDataSource.add(items).concat(self.coreDataSource.add(items))
    }

    func update(_ items: [Item]) -> Observable<[Item]> {
        return self.networkDataSource.update(items).concat(self.coreDataSource.update(items))
    }

    func clean() -> Observable<Void> {
        return self.networkDataSource.clean().concat(self.coreDataSource.clean())
    }

    func delete(byId id: String) -> Observable<Void> {
        return self.networkDataSource.delete(byId: id).concat(self.coreDataSource.delete(byId: id))
    }

}
