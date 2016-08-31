//
//  SessionsSearchPresenter.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 04/07/16.
//  Copyright © 2016 Maksym Shcheglov. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

protocol SessionsSearchPresenter: class {
    // INPUT
    
    // Defines whether or not the viewModel is active
    var active: Bool { get set }
    // Defines whether or not there are any ongoing network operation
    var isLoading: Driver<Bool> { get }
    // Item selection observer
    func itemSelectionObserver(viewModel: SessionViewModel)
    // Filter button tap observer
    func filterObserver()
    // Search string observer
    func searchStringObserver(query: String)
    
    // OUTPUT
    
    // The view's title
    var title: Driver<String> { get }
    // The array of available WWDC sessions
    var sessions: Driver<[SessionViewModels]> { get }
}
