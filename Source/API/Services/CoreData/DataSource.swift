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

protocol DataSource: class {
    associatedtype Item

    func allObjects() -> Observable<[Item]>
    func get(byId id: String) -> Observable<Item?>
    func save(_ items: [Item]) -> Observable<Void>
//    func update(_ items: [T])
    func clean() -> Observable<Void>
    func delete(byId id: String) -> Observable<Void>
}

final class AnyDataSource<T>: DataSource {
    typealias Item = T

    private let _allObjects: () -> Observable<[Item]>
    private let _get: (String) -> Observable<Item?>
    private let _save: ([Item]) -> Observable<Void>
    private let _clean: () -> Observable<Void>
    private let _delete: (String) -> Observable<Void>

    init<Concrete: DataSource>(dataSource: Concrete) where Concrete.Item == T {
        _allObjects = dataSource.allObjects
        _get = dataSource.get
        _save = dataSource.save
        _clean = dataSource.clean
        _delete = dataSource.delete
    }

    func allObjects() -> Observable<[Item]> {
        return _allObjects()
    }

    func get(byId id: String) -> Observable<Item?> {
        return _get(id)
    }

    func save(_ items: [Item]) -> Observable<Void> {
        return _save(items)
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

    func sync(in context: NSManagedObjectContext) -> Observable<CoreDataType> {
        return Observable.merge(self.map { element in
            element.sync(in: context)
        })
    }
}

extension ObservableType {
    func mapToVoid() -> Observable<Void> {
        return map { _ in }
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
        let loadedObjects = self.networkDataSource.allObjects().flatMap(self.coreDataSource.save).flatMap(self.coreDataSource.allObjects)
        return Observable.of(cachedObjects, loadedObjects).merge().sort().shareReplayLatestWhileConnected()
    }

    func get(byId id: String) -> Observable<T?> {
        let cachedObject = self.coreDataSource.get(byId: id)
        let loadedObject = self.networkDataSource.get(byId: id)
        return Observable.of(cachedObject, loadedObject).merge()
    }

    func save(_ items: [Item]) -> Observable<Void> {
        return self.networkDataSource.save(items).concat(self.coreDataSource.save(items))
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
    }

    func get(byId id: String) -> Observable<Item?> {
        // Currently not supported
        return Observable.empty()

//        return self.allObjects().flatMap({ sessions -> Observable<Item> in
//            if let session = sessions.filter({ session in
//                return session.uniqueId == id
//            }).first {
//                return Observable.just(session)
//            }
//            return Observable.empty()
//        })
    }

    func save(_ items: [Item]) -> Observable<Void> {
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
        guard let configResource = Resource(url: WWDCastEnvironment.configURL, parser: AppConfigBuilder.build) else {
            return Observable.error(WWDCastAPIError.dataLoadingError)
        }
        return self.network.load(configResource)
    }

    private func loadSessions(forConfig config: AppConfig) -> Observable<[Session]> {
        guard let sessionsResource = Resource(url: config.videosURL, parser: SessionsBuilder.build) else {
            return Observable.error(WWDCastAPIError.dataLoadingError)
        }
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
        } catch let e {
            self.allObjectsSubject.on(.error(e))
        }
    }

    func allObjects() -> Observable<[Item]> {
        return self.allObjectsSubject.asObservable()
    }

    func get(byId id: String) -> Observable<Item?> {
        return self.coreDataController.viewContext.rx.first(with: id).map { (obj: T?) -> Item? in
            return obj?.asEntity()
        }
    }

    func save(_ items: [Item]) -> Observable<Void> {
        let context = self.coreDataController.newBackgroundContext()

        return items.sync(in: context).mapToVoid().flatMap(context.rx.save)
//        return bgContext.rx.first(with: predicate).map({ (obj: T?) -> Void  in
//            let record = obj ?? T(context: bgContext)
//            record.update(item)
//        }).flatMap(bgContext.rx.save)
    }

//    func update(_ item: Session) {
//
//    }

    func clean() -> Observable<Void> {
//        let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
//        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
//        do
//        {
//            try context.execute(deleteRequest)
//            try context.save()
//        }
//        catch
//        {
//            print ("There was an error")
//        }
        return Observable.empty()
    }

    func delete(byId id: String) -> Observable<Void> {
        let bgContext = self.coreDataController.newBackgroundContext()
        let item: Observable<T?> = bgContext.rx.first(with: id)
        return item.rejectNil().unwrap().map(bgContext.delete).flatMap(bgContext.rx.save)

//        let predicate = NSPredicate(format: "(id = %@)", id)
//        self.coreDataController.performInBackground { context in
//            context.rx.first(with: predicate).subscribe(onNext: { session in
//                context.delete(session!)
//            })
//        }
    }

    // MARK: Private

    fileprivate func sendNextElement() {
        self.frc.managedObjectContext.perform {
            let records = self.frc.fetchedObjects ?? []
            self.allObjectsSubject.on(.next(records.asDomainTypes()))
        }
    }

//}
//
//extension CoreDataSource: NSFetchedResultsControllerDelegate {

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        sendNextElement()
    }

}
