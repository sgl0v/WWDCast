//
//  SessionsSearchViewModel.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 04/07/16.
//  Copyright © 2016 Maksym Shcheglov. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

import RxSwift
import RxCocoa

struct SessionsSearchViewModelInput {
    /// triggers a screen's content loading
    let loading: Driver<Void>
    /// called when the user selected an item from the list
    let selection: Driver<SessionItemViewModel>
    // triggered on filter button tap
    let filter: Driver<Void>
    // triggered when the search query is updated
    let search: Driver<String>
}

struct SessionsSearchViewModelOuput {
    // WWDC sessions
    let sessions: Driver<[SessionSectionViewModel]>
    // Emits when the content is loading
    let loading: Driver<Bool>
    /// Emits when a signup error has occurred and a message should be displayed.
    let error: Driver<Error>
}

protocol SessionsSearchViewModelType: class {
    /// Trandforms input state to the output state
    ///
    /// - Parameter input: input state
    /// - Returns: output state
    func transform(input: SessionsSearchViewModelInput) -> SessionsSearchViewModelOuput
}

protocol SessionsSearchNavigator: class {
    /// Presents the filter screen
    func showFilter()
    /// Presents the session details screen
    func showDetails(forSession sessionId: String)
}
