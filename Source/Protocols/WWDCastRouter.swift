//
//  SessionsSearchRouter.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 06/07/16.
//  Copyright © 2016 Maksym Shcheglov. All rights reserved.
//

import Foundation
import RxSwift

/// The sessions search router
protocol SessionsSearchRouter: class {
    /// Shows details for the session with specified id
    func showSessionDetails(_ sessionId: String)

    /// Shows the filter controller
    func showFilterController(_ filter: Filter, completion: @escaping (Filter) -> Void)
}

/// The sessions details router
protocol SessionDetailsRouter: class {
    /// Presents an alert with specified title and message
    func showAlert(withTitle title: String?, message: String)
    /// Presents an alert dialog with specified title, message and actions
    func showAlert<Action: CustomStringConvertible>(withTitle title: String?, message: String?, cancelAction: Action, actions: [Action]) -> Observable<Action>
}

/// The favorite sessions router
protocol FavoriteSessionsRouter: class {
    /// Shows the favorite session details
    func showFavoriteSessionDetails(_ sessionId: String)
}
