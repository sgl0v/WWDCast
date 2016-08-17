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
    func showSessionDetails(withId Id: String)
    func showFilterController()
}

protocol SessionDetailsRouter: class {
    func showAlert<Action : CustomStringConvertible>(title: String?, message: String?, style: UIAlertControllerStyle, cancelAction: Action, actions: [Action]) -> Observable<Action>
}
