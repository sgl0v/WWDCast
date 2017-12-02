//
//  NetworkServiceProtocol.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 09/07/16.
//  Copyright © 2016 Maksym Shcheglov. All rights reserved.
//

import Foundation
import RxSwift

/// Defines the Network service errors.
enum NetworkError: Error {
    /// Failed to load data from the network.
    case failedDataLoading
}

protocol NetworkServiceType: class {

    func load<T>(_ resource: Resource<T>) -> Observable<T>
}
