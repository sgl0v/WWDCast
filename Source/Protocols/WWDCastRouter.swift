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
    func showSessionDetails(session: Session)
    func showFilterController(withFilter filter: Filter, completion: (Filter) -> Void)
}

protocol SessionDetailsRouter: class {
    func showAlert(title: String, message: String)
    func promptFor<Action : CustomStringConvertible>(title: String?, message: String?, cancelAction: Action, actions: [Action]) -> Observable<Action>
}
