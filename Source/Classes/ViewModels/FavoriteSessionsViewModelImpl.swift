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
    private var sessions = [Session]()
    private let disposeBag = DisposeBag()
    
    init(api: WWDCastAPI, router: FavoriteSessionsRouter) {
        self.api = api
        self.router = router
    }
    
    // MARK: FavoriteSessionsViewModel
    
    var favoriteSessions: Driver<[SessionSectionViewModel]> {
        return self.api.favoriteSessions
            .doOnNext({ self.sessions = $0 })
            .map(SessionItemViewModelBuilder.build)
            .asDriver(onErrorJustReturn: [])
    }
    
    let title = Driver.just(NSLocalizedString("Favorites", comment: "Favorte sessions view title"))
    
    func itemSelectionObserver(viewModel: SessionItemViewModel) {
        guard let session = self.sessions.filter({ session in
            session.uniqueId == viewModel.uniqueID
        }).first else {
            return
        }
        self.router.showSessionDetails(session)
    }
    
}