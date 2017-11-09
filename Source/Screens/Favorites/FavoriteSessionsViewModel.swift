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

class FavoriteSessionsViewModel: FavoriteSessionsViewModelProtocol {
    private let useCase: FavoriteSessionsUseCaseType
    private weak var delegate: FavoriteSessionsViewModelDelegate?

    init(useCase: FavoriteSessionsUseCase, delegate: FavoriteSessionsViewModelDelegate) {
        self.useCase = useCase
        self.delegate = delegate
    }

    // MARK: FavoriteSessionsViewModel

    var favoriteSessions: Driver<[SessionSectionViewModel]> {
        return self.useCase.favoriteSessions
            .map(SessionSectionViewModelBuilder.build)
            .asDriver(onErrorJustReturn: [])
    }

    let emptyFavorites = Driver.just(EmptyDataSetViewModel(title: NSLocalizedString("No Favorites", comment: "The are no sessions added to favorites"), description: NSLocalizedString("Add your favorite sessions to the bookmarks", comment: "Add your favorite sessions to the bookmarks")))

    func didSelect(item: SessionItemViewModel) {
        self.delegate?.favoriteSessionsViewModel(self, wantsToShowSessionDetailsWith: item.id)
    }

}
