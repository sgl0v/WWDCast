//
//  FavoriteSessionsViewModel.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 21/10/2016.
//  Copyright © 2016 Maksym Shcheglov. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

struct FavoriteSessionsViewModelInput {
    /// triggers a screen's content loading
    let loading: Driver<Void>
    /// called when the user selected an item from the list
    let selection: Driver<SessionItemViewModel>
}

struct FavoriteSessionsViewModelOutput {
    // Favorite WWDC sessions
    let favorites: Driver<[SessionSectionViewModel]>
    // Emits when there are no no favorite sessions
    let empty: Driver<Bool>
    /// Emits when a signup error has occurred and a message should be displayed.
    let error: Driver<Error>
}

protocol FavoriteSessionsViewModelType: class {
    /// Trandforms input state to the output state
    ///
    /// - Parameter input: input state
    /// - Returns: output state
    func transform(input: FavoriteSessionsViewModelInput) -> FavoriteSessionsViewModelOutput
}

protocol FavoriteSessionsNavigator: class {
    /// Presents the session details screen
    func showDetails(forSession sessionId: String)
}
