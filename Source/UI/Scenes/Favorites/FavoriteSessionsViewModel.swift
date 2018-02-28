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
    private let disposeBag = DisposeBag()

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

        input.selection.map({ session in
            return session.id
        }).drive(onNext: self.navigator?.showDetails).disposed(by: self.disposeBag)

        let empty = favorites.map { sessions in
            return sessions.isEmpty
        }

        let error = errorTracker.asDriver()

        return FavoriteSessionsViewModelOutput(favorites: favorites, empty: empty, error: error)
    }

}
