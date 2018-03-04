//
//  SessionDetailsViewModelTests.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 02/03/2017.
//  Copyright © 2017 Maksym Shcheglov. All rights reserved.
//

import XCTest
import RxSwift
import RxCocoa
@testable import WWDCast

class SessionDetailsViewModelTests: XCTestCase {

    private let sessionId = "sessionId"
    private var viewModel: SessionDetailsViewModel!
    private var useCase: MockSessionDetailsUseCase!
    private var delegate: MockSessionsSearchNavigator!
    private var disposeBag: DisposeBag!

    override func setUp() {
        self.useCase = MockSessionDetailsUseCase()
        self.disposeBag = DisposeBag()
    }

    /// Test that video playback starts for specified session
    func testSessionPlaybackStarts() {
        // GIVEN
        let expectation = self.expectation(description: "didStartPlaying")
        self.useCase.sessionObservable = BehaviorSubject<Session>(value: Session.dummySession)
        let devices = [GoogleCastDevice(name: "#1", id: "1"), GoogleCastDevice(name: "#2", id: "2")]
        let selectedDevice = 1
        self.useCase.devicesObservable = BehaviorSubject<[GoogleCastDevice]>(value: devices)
        self.useCase.playObservable = { device in
            XCTAssertEqual(device.id, devices[selectedDevice].id)
            expectation.fulfill()
            return Observable.empty()
        }
        self.viewModel = SessionDetailsViewModel(useCase: self.useCase)
        let startPlayback = PublishSubject<Int>()
        let input = SessionDetailsViewModelInput(load: Driver.just(),
                                                 toggleFavorite: Driver.empty(),
                                                 showDevices: Driver.empty(),
                                                 startPlayback: startPlayback.asDriverOnErrorJustComplete())
        _ = self.viewModel.transform(input: input)

        // WHEN
        startPlayback.onNext(selectedDevice)

        // THEN
        self.waitForExpectations(timeout: 1.0, handler: nil)
    }

    /// Test that error observable emits a new value when video playback fails
    func testSessionPlaybackFails() {
        // GIVEN
        let expectation = self.expectation(description: "didFailPlaying")
        self.useCase.sessionObservable = Observable.just(Session.dummySession)
        let devices = [GoogleCastDevice(name: "#1", id: "1"), GoogleCastDevice(name: "#2", id: "2")]
        let selectedDevice = 1
        self.useCase.devicesObservable = Observable.just(devices)
        self.useCase.playObservable = { _ in
            return Observable.error(GoogleCastServiceError.playbackError)
        }
        self.viewModel = SessionDetailsViewModel(useCase: self.useCase)
        let startPlayback = PublishSubject<Int>()
        let input = SessionDetailsViewModelInput(load: Driver.just(),
                                                 toggleFavorite: Driver.empty(),
                                                 showDevices: Driver.empty(),
                                                 startPlayback: startPlayback.asDriverOnErrorJustComplete())
        let output = self.viewModel.transform(input: input)
        output.error.asObservable().subscribe(onNext: { _ in
            expectation.fulfill()
        }).disposed(by: self.disposeBag)

        // WHEN
        startPlayback.onNext(selectedDevice)

        // THEN
        self.waitForExpectations(timeout: 1.0, handler: nil)
    }

    /// Test that session Observable emits a value when the user toggles a favorite session
    func testFavoriteSessionToggle() {
        // GIVEN
        let expectation = self.expectation(description: "didToggleFavorite")
        self.useCase.sessionObservable = Observable.just(Session.dummySession)
        self.useCase.toggleObservable = Observable.just()
        self.viewModel = SessionDetailsViewModel(useCase: self.useCase)
        let toggleFavorite = PublishSubject<Void>()
        let input = SessionDetailsViewModelInput(load: Driver.just(),
                                                 toggleFavorite: toggleFavorite.asDriverOnErrorJustComplete(),
                                                 showDevices: Driver.empty(),
                                                 startPlayback: Driver.empty())
        let output = self.viewModel.transform(input: input)
        output.session.asObservable().skip(1).subscribe(onNext: { viewModel in
            XCTAssertTrue(viewModel.favorite)
            expectation.fulfill()
        }).disposed(by: self.disposeBag)

        // WHEN
        toggleFavorite.onNext()

        // THEN
        self.waitForExpectations(timeout: 1.0, handler: nil)
    }
}
