//
//  NetworkServiceProtocol.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 09/07/16.
//  Copyright © 2016 Maksym Shcheglov. All rights reserved.
//

import Foundation
import RxSwift

protocol NetworkServiceProtocol: class {

    func load<T>(_ resource: Resource<T>) -> Observable<T>
}
