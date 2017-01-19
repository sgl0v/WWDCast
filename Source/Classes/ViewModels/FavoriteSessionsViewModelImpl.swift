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

class FavoriteSessionsViewModelImpl: FavoriteSessionsViewModel {
    private let api: WWDCastAPI
    private let router: FavoriteSessionsRouter
    private let disposeBag = DisposeBag()

    init(api: WWDCastAPI, router: FavoriteSessionsRouter) {
        self.api = api
        self.router = router
    }

    // MARK: FavoriteSessionsViewModel

    var favoriteSessions: Driver<[SessionSectionViewModel]> {
        return self.api.favoriteSessions
            .map(SessionSectionViewModelBuilder.build)
            .asDriver(onErrorJustReturn: [])
    }

    let title = Driver.just(NSLocalizedString("Favorites", comment: "Favorte sessions view title"))
    let emptyFavoritesTitle = Driver.just(NSLocalizedString("No Favorites", comment: "The are no sessions added to favorites"))
    let emptyFavoritesDescription = Driver.just(NSLocalizedString("Add your favorite sessions to the bookmarks", comment: "Add your favorite sessions to the bookmarks"))

    func didSelect(item: SessionItemViewModel) {
        self.router.showFavoriteSessionDetails(item.uniqueID)
    }

}
