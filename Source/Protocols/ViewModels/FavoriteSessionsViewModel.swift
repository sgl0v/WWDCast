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

protocol FavoriteSessionsViewModel: class {
    // INPUT

    // Item selection observer
    func didSelect(item: SessionItemViewModel)

    // OUTPUT

    // The view's title
    var title: Driver<String> { get }
    // The title to show when there are no favorite sessions
    var emptyFavoritesTitle: Driver<String> { get }
    // The description to show when there are no favorite sessions
    var emptyFavoritesDescription: Driver<String> { get }
    // The array of available WWDC sessions divided into sections
    var favoriteSessions: Driver<[SessionSectionViewModel]> { get }
}
