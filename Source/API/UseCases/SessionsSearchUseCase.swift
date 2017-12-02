//
//  SessionsSearchUserCase.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 09/11/2017.
//  Copyright © 2017 Maksym Shcheglov. All rights reserved.
//

import Foundation
import RxSwift

protocol SessionsSearchUseCaseType {

    /// The sequence of WWDC Sessions
    var sessions: Observable<[Session]> { get }
}

class SessionsSearchUseCase: SessionsSearchUseCaseType {

    private let dataSource: AnyDataSource<Session>

    init(dataSource: AnyDataSource<Session>) {
        self.dataSource = dataSource
    }

    lazy var sessions: Observable<[Session]> = {
        return self.dataSource.allObjects().shareReplayLatestWhileConnected()
    }()

}
