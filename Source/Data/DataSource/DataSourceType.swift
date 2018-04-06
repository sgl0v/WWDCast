//
//  DataSource.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 23/05/2017.
//  Copyright © 2017 Maksym Shcheglov. All rights reserved.
//

import Foundation
import RxSwift

protocol DataSourceType: class {
    associatedtype Item

    /// Fetches and returns all available items if type Item
    ///
    /// - Returns: an observable sequence of items
    func allObjects() -> Observable<[Item]>

    /// Fetches an item with specified id
    ///
    /// - Parameter id: The items identifier
    /// - Returns: an observable sequence
    func get(byId id: String) -> Observable<Item>

    /// Adds items to the data source
    ///
    /// - Parameter items: The items to add
    /// - Returns: an observable sequence of recently added items
    func add(_ items: [Item]) -> Observable<[Item]>

    /// Updates items in the data source.
    ///
    /// - Parameter items: an array of records to update.
    /// - Returns: an observable sequence of recently updated items
    func update(_ items: [Item]) -> Observable<[Item]>

    /// Removes all items of type Item from the data source
    ///
    /// - Returns: an observable sequence
    func clean() -> Observable<Void>

    /// Removes item with specified id from the data source
    ///
    /// - Returns: an observable sequence
    func delete(byId id: String) -> Observable<Void>
}
