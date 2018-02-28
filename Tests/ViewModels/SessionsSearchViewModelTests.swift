//
//  SessionsSearchViewModelTests.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 01/03/2017.
//  Copyright © 2017 Maksym Shcheglov. All rights reserved.
//

import XCTest
import RxSwift
@testable import WWDCast

class SessionsSearchViewModelTests: XCTestCase {

    private var viewModel: SessionsSearchViewModel!
    private var api: MockWWDCastAPI!
    private var delegate: MockSessionsSearchViewModelDelegate!
    private var disposeBag: DisposeBag!

    override func setUp() {
        self.api = MockWWDCastAPI()
        self.delegate = MockSessionsSearchViewModelDelegate()
        self.viewModel = SessionsSearchViewModel(api: self.api, delegate: self.delegate)
        self.disposeBag = DisposeBag()
    }

    /// Tests that viewModel loads data via WWDCastAPI and `sessionSections` emits a new value
    func testSessionsLoading() {
        // GIVEN
        let sessions = SessionsLoader.sessionsFromFile(withName: "sessions.json")
        var sessionViewModels: [SessionSectionViewModel]?
        self.api.sessionsObservable = Observable.just(sessions)
        let expectation = self.expectation(description: "didFinishDataLoading")
        var isError = false

        // WHEN
        self.viewModel.sessionSections.asObservable().subscribe(onNext: { sessions in
            sessionViewModels = sessions
            expectation.fulfill()
        }, onError: { _ in
            isError = true
        }).disposed(by: self.disposeBag)

        // THEN
        waitForExpectations(timeout: 1.0, handler: nil)
        XCTAssertFalse(isError)
        XCTAssertNotNil(sessionViewModels)
    }

    /// Tests that `sessionSections` emits a new value when the search string is changed
    func testSessionsUpdatedOnSearch() {
        // GIVEN
        let sessions = SessionsLoader.sessionsFromFile(withName: "sessions.json")
        var sessionViewModels: [SessionSectionViewModel]?
        self.api.sessionsObservable = Observable.just(sessions)
        let expectation = self.expectation(description: "didFinishDataLoading")
        var isError = false

        // WHEN
        self.viewModel.sessionSections.asObservable().skip(1).subscribe(onNext: { sessions in
            sessionViewModels = sessions
            expectation.fulfill()
        }, onError: { _ in
            isError = true
        }).disposed(by: self.disposeBag)
        self.viewModel.didStartSearch(withQuery: "swift")

        // THEN
        waitForExpectations(timeout: 1.0, handler: nil)
        XCTAssertFalse(isError)
        XCTAssertNotNil(sessionViewModels)
    }

    /// The viewModel's delegate should be notified when the user selects a session item
    func testNotifyDelegateOnItemSelection() {
        //GIVEN
        let sessionItem = SessionItemViewModel.dummyItem
        let expectation = self.expectation(description: "didSelectItem")
        var selectedSessionId: String?
        self.delegate.detailsHandler = { viewModel, sessionId in
            XCTAssertTrue(self.viewModel === viewModel)
            selectedSessionId = sessionId
            expectation.fulfill()
        }

        // WHEN
        self.viewModel.didSelect(item: sessionItem)

        // THEN
        waitForExpectations(timeout: 1.0, handler: nil)
        XCTAssertNotNil(selectedSessionId)
        XCTAssertEqual(sessionItem.id, selectedSessionId!)
    }

    /// The viewModel's delegate should be notified when the user taps the filter button
    func testNotifyDelegateOnFilterButtonTap() {
        //GIVEN
        let expectation = self.expectation(description: "didTapFilter")
        self.delegate.filterHandler = { _ in
            expectation.fulfill()
        }

        // WHEN
        self.viewModel.didTapFilter()

        // THEN
        waitForExpectations(timeout: 1.0, handler: nil)
    }

}
