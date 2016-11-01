//
//  SessionsSearchViewModel.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 04/07/16.
//  Copyright © 2016 Maksym Shcheglov. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

protocol SessionsSearchViewModel: class {
    // INPUT
    
    // Item selection observer
    func itemSelectionObserver(_ viewModel: SessionItemViewModel)
    // Filter button tap observer
    func filterObserver()
    // Search string observer
    func searchStringObserver(_ query: String)
    
    // OUTPUT

    // Defines whether or not there are any ongoing network operation
    var isLoading: Driver<Bool> { get }
    // The view's title
    var title: Driver<String> { get }
    // The array of available WWDC sessions divided into sections
    var sessionSections: Driver<[SessionSectionViewModel]> { get }
}
