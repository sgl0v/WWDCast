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

class FavoriteSessionsViewModel: FavoriteSessionsViewModelType {
    private let useCase: FavoriteSessionsUseCaseType
    private weak var navigator: FavoriteSessionsNavigator?

    init(useCase: FavoriteSessionsUseCaseType, navigator: FavoriteSessionsNavigator) {
        self.useCase = useCase
        self.navigator = navigator
    }

    // MARK: FavoriteSessionsViewModel

    func transform(input: FavoriteSessionsViewModelInput) -> FavoriteSessionsViewModelOutput {
        let errorTracker = ErrorTracker()

        let favorites: Driver<[SessionSectionViewModel]> = input.loading.flatMapLatest {
            self.useCase.favoriteSessions
                .map(SessionSectionViewModelBuilder.build)
                .trackError(errorTracker)
                .asDriverOnErrorJustComplete()
        }

        let selectedItem = input.selection.do(onNext: { session in
            self.navigator?.showDetails(forSession: session.id)
        })

        let empty = favorites.map { sessions in
            return sessions.isEmpty
        }

        let error = errorTracker.asDriver()

        return FavoriteSessionsViewModelOutput(favorites: favorites, selectedItem: selectedItem, empty: empty, error: error)
    }

}
