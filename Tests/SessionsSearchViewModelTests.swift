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
        let sessions = [Session]()
        var sessionViewModels: [SessionSectionViewModel]?
        self.api.sessionsObservable = Observable.just(sessions)
        let expectation = self.expectation(description: "")
        var isError = false

        // WHEN
        self.viewModel.sessionSections.asObservable().subscribe(onNext: { sessions in
            sessionViewModels = sessions
            expectation.fulfill()
        }, onError: { _ in
            isError = true
        }).addDisposableTo(self.disposeBag)

        // THEN
        waitForExpectations(timeout: 1.0, handler: nil)
        XCTAssertFalse(isError)
        XCTAssertNotNil(sessionViewModels)
    }

    /// Tests that `sessionSections` emits a new value when the search string is changed
    func testSessionsUpdatedOnSearch() {
        // GIVEN
        let sessions = [Session]()
        var sessionViewModels: [SessionSectionViewModel]?
        self.api.sessionsObservable = Observable.just(sessions)
        let expectation = self.expectation(description: "")
        var isError = false

        // WHEN
        self.viewModel.sessionSections.asObservable().skip(1).subscribe(onNext: { sessions in
            sessionViewModels = sessions
            expectation.fulfill()
        }, onError: { _ in
            isError = true
        }).addDisposableTo(self.disposeBag)
        self.viewModel.didStartSearch(withQuery: "swift")

        // THEN
        waitForExpectations(timeout: 1.0, handler: nil)
        XCTAssertFalse(isError)
        XCTAssertNotNil(sessionViewModels)
    }

}
