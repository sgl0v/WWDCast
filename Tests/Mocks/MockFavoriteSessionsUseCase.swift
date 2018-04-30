//
//  MockFavoriteSessionsUseCase.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 05/04/2018.
//  Copyright © 2018 Maksym Shcheglov. All rights reserved.
//

import Foundation
import RxSwift
import UIKit
@testable import WWDCast

class MockFavoriteSessionsUseCase: FavoriteSessionsUseCaseType {

    typealias SessionsObservable = Observable<[Session]>
    typealias ImageLoadObservable = (URL) -> Observable<UIImage>

    var sessionsObservable: SessionsObservable?
    var imageLoadObservable: ImageLoadObservable?

    var favoriteSessions: Observable<[Session]> {
        guard let observable = self.sessionsObservable else {
            fatalError("Not implemented")
        }
        return observable
    }

    func loadImage(for url: URL) -> Observable<UIImage> {
        guard let observable = self.imageLoadObservable else {
            fatalError("Not implemented")
        }
        return observable(url)
    }
}
