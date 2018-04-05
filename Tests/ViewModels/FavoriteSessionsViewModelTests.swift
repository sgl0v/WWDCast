//
//  FavoriteSessionsViewModel.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 02/03/2017.
//  Copyright © 2017 Maksym Shcheglov. All rights reserved.
//

import XCTest
import RxSwift
import RxCocoa
@testable import WWDCast

class FavoriteSessionsViewModelTests: XCTestCase {

    private var viewModel: FavoriteSessionsViewModel!
    private var useCase: MockFavoriteSessionsUseCase!
    private var navigator: MockFavoriteSessionsNavigator!
    private var disposeBag: DisposeBag!


    override func setUp() {
        self.useCase = MockFavoriteSessionsUseCase()
        self.navigator = MockFavoriteSessionsNavigator()
        self.viewModel = FavoriteSessionsViewModel(useCase: self.useCase, navigator: self.navigator)
        self.disposeBag = DisposeBag()
    }

    /// Tests that viewModel triggers data loading and `output.favorites` emits a new value
    func testFavoriteSessionsLoading() {
        // GIVEN
        let sessions = SessionsLoader.sessionsFromFile(withName: "sessions.json")
        var sessionViewModels: [SessionSectionViewModel]?
        self.useCase.sessionsObservable = Observable.just(sessions)
        let expectation = self.expectation(description: "didFinishDataLoading")
        let loading = PublishSubject<Void>()
        let input = FavoriteSessionsViewModelInput(appear: loading.asDriverOnErrorJustComplete(),
                                                 disappear: Driver.never(),
                                                 selection: Driver.never())
        let output = self.viewModel.transform(input: input)
        output.favorites.drive(onNext: { sessions in
            sessionViewModels = sessions
            expectation.fulfill()
        }).disposed(by: self.disposeBag)

        // WHEN
        loading.onNext(())

        // THEN
        waitForExpectations(timeout: 1.0, handler: nil)
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
        let input = FavoriteSessionsViewModelInput(appear: Driver.just(()),
                                                 disappear: Driver.never(),
                                                 selection: selection.asDriverOnErrorJustComplete())
        _ = self.viewModel.transform(input: input)

        // WHEN
        selection.onNext(sessionItem)

        // THEN
        waitForExpectations(timeout: 1.0, handler: nil)
        XCTAssertNotNil(selectedSessionId)
        XCTAssertEqual(sessionItem.id, selectedSessionId!)
    }

}
