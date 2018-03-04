//
//  SessionsSearchViewModelTests.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 01/03/2017.
//  Copyright © 2017 Maksym Shcheglov. All rights reserved.
//

import XCTest
import RxSwift
import RxCocoa
@testable import WWDCast

class SessionsSearchViewModelTests: XCTestCase {

    private var viewModel: SessionsSearchViewModel!
    private var useCase: MockSessionsSearchUseCase!
    private var navigator: MockSessionsSearchNavigator!
    private var disposeBag: DisposeBag!

    override func setUp() {
        self.useCase = MockSessionsSearchUseCase()
        self.navigator = MockSessionsSearchNavigator()
        self.viewModel = SessionsSearchViewModel(useCase: self.useCase, navigator: self.navigator)
        self.disposeBag = DisposeBag()
    }

    /// Tests that viewModel triggers data loading and `output.sessions` emits a new value
    func testSessionsLoading() {
        // GIVEN
        let sessions = SessionsLoader.sessionsFromFile(withName: "sessions.json")
        var sessionViewModels: [SessionSectionViewModel]?
        self.useCase.sessionsObservable = Observable.just(sessions)
        let expectation = self.expectation(description: "didFinishDataLoading")
        var isError = false
        let loading = PublishSubject<Void>()
        let input = SessionsSearchViewModelInput(loading: loading.asDriverOnErrorJustComplete(),
                                                 selection: Driver.empty(),
                                                 filter: Driver.empty(),
                                                 search: Driver.empty())
        let output = self.viewModel.transform(input: input)
        output.sessions.asObservable().subscribe(onNext: { sessions in
            sessionViewModels = sessions
            expectation.fulfill()
        }, onError: { _ in
            isError = true
        }).disposed(by: self.disposeBag)

        // WHEN
        loading.onNext()

        // THEN
        waitForExpectations(timeout: 1.0, handler: nil)
        XCTAssertFalse(isError)
        XCTAssertNotNil(sessionViewModels)
    }

    /// Tests that `output.sessions` emits a new value when the search string is changed
    func testSessionsUpdatedOnSearch() {
        // GIVEN
        let sessions = SessionsLoader.sessionsFromFile(withName: "sessions.json")
        var sessionViewModels: [SessionSectionViewModel]?
        let searchSessions = BehaviorSubject<[Session]>(value: sessions)
        self.useCase.sessionsObservable = searchSessions.asObservable()
        self.useCase.searchObservable = { query in
            let filteredSessions = sessions.apply(Filter(query: query))
            searchSessions.onNext(filteredSessions)
            return searchSessions.asObservable()
        }
        let expectation = self.expectation(description: "didFinishDataLoading")
        var isError = false
        let search = PublishSubject<String>()
        let input = SessionsSearchViewModelInput(loading: Driver.just(),
                                                 selection: Driver.empty(),
                                                 filter: Driver.empty(),
                                                 search: search.asDriverOnErrorJustComplete())
        let output = self.viewModel.transform(input: input)
        output.sessions.asObservable().skip(1).subscribe(onNext: { sessions in
            sessionViewModels = sessions
            expectation.fulfill()
        }, onError: { _ in
            isError = true
        }).disposed(by: self.disposeBag)

        // WHEN
        search.onNext("swift")

        // THEN
        waitForExpectations(timeout: 1.0, handler: nil)
        XCTAssertFalse(isError)
        XCTAssertNotNil(sessionViewModels)
    }

    /// The navigator should be notified when the user selects a session item
    func testNotifyDelegateOnItemSelection() {
        //GIVEN
        let sessionItem = SessionItemViewModel.dummyItem
        let expectation = self.expectation(description: "didSelectItem")
        var selectedSessionId: String?
        self.navigator.detailsHandler = { sessionId in
            selectedSessionId = sessionId
            expectation.fulfill()
        }
        let selection = PublishSubject<SessionItemViewModel>()
        let input = SessionsSearchViewModelInput(loading: Driver.just(),
                                                 selection: selection.asDriverOnErrorJustComplete(),
                                                 filter: Driver.empty(),
                                                 search: Driver.empty())
        _ = self.viewModel.transform(input: input)

        // WHEN
        selection.onNext(sessionItem)

        // THEN
        waitForExpectations(timeout: 1.0, handler: nil)
        XCTAssertNotNil(selectedSessionId)
        XCTAssertEqual(sessionItem.id, selectedSessionId!)
    }

    /// The navigator should be notified when the user taps the filter button
    func testNotifyDelegateOnFilterButtonTap() {
        //GIVEN
        let expectation = self.expectation(description: "didTapFilter")
        self.navigator.filterHandler = { _ in
            expectation.fulfill()
        }
        let filter = PublishSubject<Void>()
        let input = SessionsSearchViewModelInput(loading: Driver.just(),
                                                 selection: Driver.empty(),
                                                 filter: filter.asDriverOnErrorJustComplete(),
                                                 search: Driver.empty())
        _ = self.viewModel.transform(input: input)

        // WHEN
        filter.onNext()

        // THEN
        waitForExpectations(timeout: 1.0, handler: nil)
    }

}
