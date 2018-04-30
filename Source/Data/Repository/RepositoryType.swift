//
//  RepositoryType.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 23/05/2017.
//  Copyright © 2017 Maksym Shcheglov. All rights reserved.
//

import Foundation
import RxSwift

protocol RepositoryType: class {
    associatedtype Element

    /// Returns an observable element
    ///
    /// - Returns: an observable element
    func asObservable() -> Observable<Element>

    /// Adds items to the repository
    ///
    /// - Parameter items: an object to add
    /// - Returns: an observable element
    func add(_ element: Element) -> Observable<Element>

    /// Updates items in the repository.
    ///
    /// - Parameter items: an object to update
    /// - Returns: an observable element
    func update(_ element: Element) -> Observable<Element>

    /// Performs repository cleanup
    ///
    /// - Returns: an observable sequence
    func clean() -> Observable<Void>
}
