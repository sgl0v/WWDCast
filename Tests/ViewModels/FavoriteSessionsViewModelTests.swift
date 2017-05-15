//
//  FavoriteSessionsViewModel.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 02/03/2017.
//  Copyright © 2017 Maksym Shcheglov. All rights reserved.
//

import XCTest
import RxSwift
import SwiftyJSON
@testable import WWDCast

class FavoriteSessionsViewModelTests: XCTestCase {

    private var viewModel: FavoriteSessionsViewModel!
    private var api: MockWWDCastAPI!
    private var delegate: MockFavoriteSessionsViewModelDelegate!
    private var disposeBag: DisposeBag!

    override func setUp() {
        self.api = MockWWDCastAPI()
        self.delegate = MockFavoriteSessionsViewModelDelegate()
        self.viewModel = FavoriteSessionsViewModel(api: self.api, delegate: self.delegate)
        self.disposeBag = DisposeBag()
    }

    /// Tests that viewModel loads data via WWDCastAPI and `favoriteSessions` emits a new value
    func testFavoriteSessionsLoading() {
        // GIVEN
        let sessions = SessionsLoader.sessionsFromFile(withName: "sessions.json")
        var sessionViewModels: [SessionSectionViewModel]?
        self.api.favoritesObservable = Observable.just(sessions)
        let expectation = self.expectation(description: "didFinishDataLoading")
        var isError = false

        // WHEN
        self.viewModel.favoriteSessions.asObservable().subscribe(onNext: { sessions in
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
        XCTAssertEqual(sessionItem.uniqueID, selectedSessionId!)
    }

}
