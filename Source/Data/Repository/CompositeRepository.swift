//
//  CompositeRepository.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 07/06/2017.
//  Copyright © 2017 Maksym Shcheglov. All rights reserved.
//

import Foundation
import RxSwift

final class CompositeRepository<T>: RepositoryType {

    typealias Element = T

    private let remoteRepository: AnyRepository<T>
    private let localRepository: AnyRepository<T>

    init(remoteRepository: AnyRepository<T>, localRepository: AnyRepository<T>) {
        self.remoteRepository = remoteRepository
        self.localRepository = localRepository
    }

    func asObservable() -> Observable<Element> {
        return self._allObjects
    }

    lazy var _allObjects: Observable<Element> = {
        let cachedObjects = self.localRepository.asObservable()
        let loadedObjects = self.remoteRepository.asObservable().flatMap(self.localRepository.add)
        return Observable.of(cachedObjects, loadedObjects)
            .merge()
            .share(replay: 1)
    }()

    func add(_ value: Element) -> Observable<Element> {
        return self.remoteRepository.add(value).concat(self.localRepository.add(value))
    }

    func update(_ value: Element) -> Observable<Element> {
        return self.remoteRepository.update(value).concat(self.localRepository.update(value))
    }

    func clean() -> Observable<Void> {
        return self.remoteRepository.clean().concat(self.localRepository.clean())
    }

}
