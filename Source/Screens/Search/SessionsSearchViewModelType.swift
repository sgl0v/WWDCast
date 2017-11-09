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

/// The actions
///
/// - select: Item selection
/// - filter: Filter button tap
/// - search: Search
enum SessionsSearchAction {
    case select(SessionItemViewModel)
    case filter
    case search(String)
}

/// The session search screen state
///
/// - loading: Defines whether or not there are any ongoing network operation
/// - loaded: The array of available WWDC sessions divided into sections
enum SessionsSearchState {
    case loading
    case loaded([SessionSectionViewModel])
    case error
}

//protocol ViewModelType: class {
//    associatedtype Action
//    associatedtype State
//
//    func handle(_ action: Action) -> Observable<Type>
//}

protocol SessionsSearchViewModelType: class {

    // INPUT
    func transform(_ action: SessionsSearchAction) -> Driver<SessionsSearchState>

//    // Item selection observer
//    func didSelect(item: SessionItemViewModel)
//    // Filter button tap observer
//    func didTapFilter()
//    // Search string observer
//    func didStartSearch(withQuery query: String)
//
//    // OUTPUT
////    var state: Observable<State> { get }
//
//    // Defines whether or not there are any ongoing network operation
//    var isLoading: Driver<Bool> { get }
//    // The array of available WWDC sessions divided into sections
//    var sessionSections: Driver<[SessionSectionViewModel]> { get }
}

protocol SessionsSearchViewModelDelegate: class {
    func sessionsSearchViewModel(_ viewModel: SessionsSearchViewModelType, wantsToShow filter: Filter, completion: @escaping (Filter) -> Void)
    func sessionsSearchViewModel(_ viewModel: SessionsSearchViewModelType, wantsToShowSessionDetailsWith sessionId: String)
}
