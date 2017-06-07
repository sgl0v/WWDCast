//
//  DataSource.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 23/05/2017.
//  Copyright © 2017 Maksym Shcheglov. All rights reserved.
//

import Foundation
import RxSwift
import CoreData

enum DataSourceError: Swift.Error {
    case itemNotFound
}

protocol DataSource: class {
    associatedtype Item

    func allObjects() -> Observable<[Item]>
    func get(byId id: String) -> Observable<Item>
    func add(_ items: [Item]) -> Observable<[Item]>
    func update(_ items: [Item]) -> Observable<[Item]>
    func clean() -> Observable<Void>
    func delete(byId id: String) -> Observable<Void>
}

final class AnyDataSource<T>: DataSource {
    typealias Item = T

    private let _allObjects: () -> Observable<[Item]>
    private let _get: (String) -> Observable<Item>
    private let _add: ([Item]) -> Observable<[Item]>
    private let _update: ([Item]) -> Observable<[Item]>
    private let _clean: () -> Observable<Void>
    private let _delete: (String) -> Observable<Void>

    init<Concrete: DataSource>(dataSource: Concrete) where Concrete.Item == T {
        _allObjects = dataSource.allObjects
        _get = dataSource.get
        _add = dataSource.add
        _update = dataSource.update
        _clean = dataSource.clean
        _delete = dataSource.delete
    }

    func allObjects() -> Observable<[Item]> {
        return _allObjects()
    }

    func get(byId id: String) -> Observable<Item> {
        return _get(id)
    }

    func add(_ items: [Item]) -> Observable<[Item]> {
        return _add(items)
    }

    func update(_ items: [Item]) -> Observable<[Item]> {
        return _update(items)
    }

    func clean() -> Observable<Void> {
        return _clean()
    }

    func delete(byId id: String) -> Observable<Void> {
        return _delete(id)
    }

}

extension Sequence where Iterator.Element : EntityRepresentable {

    func asDomainTypes() -> [Iterator.Element.EntityType] {
        return self.map({ record in
            return record.asEntity()
        })
    }
}

extension Sequence where Iterator.Element : CoreDataRepresentable, Iterator.Element.CoreDataType: NSManagedObject {

    typealias CoreDataType = Iterator.Element.CoreDataType

    func sync(in context: NSManagedObjectContext) -> Observable<[CoreDataType]> {
        return Observable.merge(self.map { element in
            element.sync(in: context)
        }).toArray()
    }

    func update(in context: NSManagedObjectContext) -> Observable<[CoreDataType]> {
        return Observable.merge(self.map { element in
            element.update(in: context)
        }).toArray()
    }

}

final class CompositeDataSource<T: Comparable>: DataSource {

    typealias Item = T

    private let networkDataSource: AnyDataSource<T>
    private let coreDataSource: AnyDataSource<T>

    init(networkDataSource: AnyDataSource<T>, coreDataSource: AnyDataSource<T>) {
        self.networkDataSource = networkDataSource
        self.coreDataSource = coreDataSource
    }

    func allObjects() -> Observable<[Item]> {
        let cachedObjects = self.coreDataSource.allObjects()
        let loadedObjects = self.networkDataSource.allObjects().flatMap(self.coreDataSource.add)
        return Observable.of(cachedObjects, loadedObjects).merge().sort()
    }

    func get(byId id: String) -> Observable<T> {
        let cachedObject = self.coreDataSource.get(byId: id)
        let loadedObject = self.networkDataSource.get(byId: id)
        return Observable.of(cachedObject, loadedObject).merge()
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

final class NetworkDataSource: DataSource {
    typealias Item = Session

    private let reachability: ReachabilityServiceProtocol
    private let network: NetworkServiceProtocol

    init(network: NetworkServiceProtocol, reachability: ReachabilityServiceProtocol) {
        self.network = network
        self.reachability = reachability
    }

    func allObjects() -> Observable<[Item]> {
        return self.loadConfig()
            .flatMapLatest(self.loadSessions)
            .retryOnBecomesReachable([], reachabilityService: self.reachability)
            .shareReplayLatestWhileConnected()
    }

    func get(byId id: String) -> Observable<Item> {
        // Currently not supported
        return Observable.empty()
    }

    func add(_ items: [Item]) -> Observable<[Item]> {
        // Currently not supported
        return Observable.empty()
    }

    func update(_ items: [Item]) -> Observable<[Item]> {
        // Currently not supported
        return Observable.empty()
    }

    func clean() -> Observable<Void> {
        // Currently not supported
        return Observable.empty()
    }

    func delete(byId id: String) -> Observable<Void> {
        // Currently not supported
        return Observable.empty()
    }

    // MARK: Private

    private func loadConfig() -> Observable<AppConfig> {
        let configResource = Resource(url: WWDCastEnvironment.configURL, parser: AppConfigBuilder.build)
        return self.network.load(configResource)
    }

    private func loadSessions(forConfig config: AppConfig) -> Observable<[Session]> {
        let sessionsResource = Resource(url: config.videosURL, parser: SessionsBuilder.build)
        return self.network.load(sessionsResource)
    }

}

final class CoreDataSource<T: NSManagedObject>: NSObject, DataSource, NSFetchedResultsControllerDelegate where T: CoreDataPersistable & EntityRepresentable, T.EntityType.CoreDataType == T {

    typealias Item = T.EntityType

    fileprivate let coreDataController: CoreDataController
    fileprivate let allObjectsSubject: BehaviorSubject<[Item]>
    fileprivate let frc: NSFetchedResultsController<T>

    init(coreDataController: CoreDataController) {
        self.coreDataController = coreDataController
        self.allObjectsSubject = BehaviorSubject(value: [])

        self.frc = NSFetchedResultsController(fetchRequest: T.fetchRequest(),
                                              managedObjectContext: self.coreDataController.viewContext,
                                              sectionNameKeyPath: nil,
                                              cacheName: nil)
        super.init()
        self.frc.delegate = self
        do {
            try self.frc.performFetch()
            sendNextElement()
        } catch {
            self.allObjectsSubject.on(.error(error))
        }
    }

    func allObjects() -> Observable<[Item]> {
        return self.allObjectsSubject.asObservable()
    }

    func get(byId id: String) -> Observable<Item> {
        return self.allObjects().flatMap({ items -> Observable<Item> in
            let item = items.filter({ item in
                return item.uid == id
            }).first
            if let item = item {
                return Observable.just(item)
            }
            return Observable.error(DataSourceError.itemNotFound)
        })

//        return self.coreDataController.viewContext.rx.first(with: id).flatMap { (obj: T?) -> Observable<Item> in
//            if let item = obj {
//                return Observable.just(item.asEntity())
//            }
//            return Observable.error(DataSourceError.itemNotFound)
//        }
    }

    func add(_ items: [Item]) -> Observable<[Item]> {
        let context = self.coreDataController.newBackgroundContext()
        return items.sync(in: context).flatMap({ items in
            return context.rx.save().flatMap(Observable.just(items.asDomainTypes()))
        })
    }

    func update(_ items: [Item]) -> Observable<[Item]> {
        let context = self.coreDataController.newBackgroundContext()
        return items.update(in: context).flatMap({ items in
            return context.rx.save().flatMap(Observable.just(items.asDomainTypes()))
        })
    }

    func clean() -> Observable<Void> {
        return Observable.create({[unowned self] observer in
            let context = self.coreDataController.newBackgroundContext()
            let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: T.entityName)
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
            do {
                try context.execute(deleteRequest)
                try context.save()
                observer.onNext()
            } catch {

                assertionFailure(error.localizedDescription)
                observer.onError(error)
            }
            observer.onCompleted()
            return Disposables.create()
        })
    }

    func delete(byId id: String) -> Observable<Void> {
        let bgContext = self.coreDataController.newBackgroundContext()
        let item: Observable<T?> = bgContext.rx.first(with: id)
        return item.rejectNil().unwrap().map(bgContext.delete).flatMap(bgContext.rx.save)
    }

    // MARK: Private

    fileprivate func sendNextElement() {
        self.frc.managedObjectContext.perform {
            let records = self.frc.fetchedObjects ?? []
            NSLog("Fetched \(records.count) records!")
            self.allObjectsSubject.on(.next(records.asDomainTypes()))
        }
    }

    // MARK: NSFetchedResultsControllerDelegate

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        sendNextElement()
    }

}
