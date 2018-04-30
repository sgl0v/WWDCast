//
//  FavoriteSessionsUseCase.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 01/12/2017.
//  Copyright © 2017 Maksym Shcheglov. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

protocol FavoriteSessionsUseCaseType {

    /// The sequence of favorite WWDC Sessions
    var favoriteSessions: Observable<[Session]> { get }

    // Loads image for the given URL
    func loadImage(for url: URL) -> Observable<UIImage>
}

class FavoriteSessionsUseCase: FavoriteSessionsUseCaseType {

    private let sessionsRepository: AnyRepository<[Session]>
    private let imageLoader: ImageLoaderServiceType

    init(sessionsRepository: AnyRepository<[Session]>, imageLoader: ImageLoaderServiceType) {
        self.sessionsRepository = sessionsRepository
        self.imageLoader = imageLoader
    }

    lazy var favoriteSessions: Observable<[Session]> = {
        return self.sessionsRepository
            .asObservable()
            .sort()
            .map({ sessions in return sessions.filter({ $0.favorite }) })
            .subscribeOn(Scheduler.backgroundWorkScheduler)
            .observeOn(Scheduler.mainScheduler)
    }()

    func loadImage(for url: URL) -> Observable<UIImage> {
        return self.imageLoader.loadImage(for: url)
    }

}
