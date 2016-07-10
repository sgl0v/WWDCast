//
//  SessionsSearchInteractor.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 04/07/16.
//  Copyright © 2016 Maksym Shcheglov. All rights reserved.
//

import Foundation
import RxSwift

protocol SessionsSearchInteractor: class {
    func loadSessions() -> Observable<[Session]>
    func playSession(session: Session)
}
