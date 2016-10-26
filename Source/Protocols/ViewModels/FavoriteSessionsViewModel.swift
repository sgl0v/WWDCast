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
    func itemSelectionObserver(viewModel: SessionItemViewModel)
    
    // OUTPUT
    
    // The view's title
    var title: Driver<String> { get }
    // The array of available WWDC sessions divided into sections
    var favoriteSessions: Driver<[SessionSectionViewModel]> { get }
}
