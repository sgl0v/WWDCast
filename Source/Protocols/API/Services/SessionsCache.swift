//
//  SessionsCache.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 21/10/2016.
//  Copyright © 2016 Maksym Shcheglov. All rights reserved.
//

import Foundation
import RxSwift

protocol SessionsCache: class {
    
    var sessions: Observable<[Session]> { get }
    
    func save(_ sessions: [Session])
    func load() -> [Session]
    func update(_ sessions: [Session])
}
