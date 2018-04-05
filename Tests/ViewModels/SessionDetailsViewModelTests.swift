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
        self.useCase.sessionObservable = Observable.just(Session.dummySession)
        let devices = [GoogleCastDevice(name: "#1", id: "1"), GoogleCastDevice(name: "#2", id: "2")]
        let selectedDevice = 1
        self.useCase.devicesObservable = Observable.just(devices)
        self.useCase.playObservable = { device in
            XCTAssertEqual(device.id, devices[selectedDevice].id)
            return Observable.just(())
        }
        self.viewModel = SessionDetailsViewModel(useCase: self.useCase)
        let startPlayback = PublishSubject<Int>()
        let input = SessionDetailsViewModelInput(appear: Driver.just(()),
                                                 disappear: Driver.never(),
                                                 toggleFavorite: Driver.never(),
                                                 showDevices: Driver.never(),
                                                 startPlayback: startPlayback.asDriverOnErrorJustComplete())
        let output = self.viewModel.transform(input: input)
        output.playback.drive(onNext: { _ in
            expectation.fulfill()
        }).disposed(by: self.disposeBag)

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
        let input = SessionDetailsViewModelInput(appear: Driver.just(()),
                                                 disappear: Driver.never(),
                                                 toggleFavorite: Driver.never(),
                                                 showDevices: Driver.never(),
                                                 startPlayback: startPlayback.asDriverOnErrorJustComplete())
        let output = self.viewModel.transform(input: input)
        output.error.asObservable().subscribe(onNext: { _ in
            expectation.fulfill()
        }).disposed(by: self.disposeBag)
        output.playback.drive().disposed(by: self.disposeBag)

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
        self.useCase.toggleObservable = Observable.just(())
        self.useCase.devicesObservable = Observable.never()
        self.viewModel = SessionDetailsViewModel(useCase: self.useCase)
        let toggleFavorite = PublishSubject<Void>()
        let input = SessionDetailsViewModelInput(appear: Driver.just(()),
                                                 disappear: Driver.never(),
                                                 toggleFavorite: toggleFavorite.asDriverOnErrorJustComplete(),
                                                 showDevices: Driver.never(),
                                                 startPlayback: Driver.never())
        let output = self.viewModel.transform(input: input)
        output.session.skip(1).drive(onNext: { viewModel in
            expectation.fulfill()
        }).disposed(by: self.disposeBag)

        // WHEN
        toggleFavorite.onNext(())

        // THEN
        self.waitForExpectations(timeout: 1.0, handler: nil)
    }
}
