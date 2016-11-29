//
//  SessionsSearchRouter.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 06/07/16.
//  Copyright © 2016 Maksym Shcheglov. All rights reserved.
//

import Foundation
import RxSwift

protocol SessionsSearchRouter: class {
    func showSessionDetails(_ sessionId: String)
    func showFilterController(_ filter: Filter, completion: @escaping (Filter) -> Void)
}

protocol SessionDetailsRouter: class {
    func showAlert(withTitle title: String?, message: String)
    func promptFor<Action : CustomStringConvertible>(_ title: String?, message: String?, cancelAction: Action, actions: [Action]) -> Observable<Action>
}

protocol FavoriteSessionsRouter: class {
    func showFavoriteSessionDetails(_ sessionId: String)
}
