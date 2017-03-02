//
//  SessionDetailsViewModelTests.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 02/03/2017.
//  Copyright © 2017 Maksym Shcheglov. All rights reserved.
//

import XCTest
import RxSwift
@testable import WWDCast

class SessionDetailsViewModelTests: XCTestCase {

    private let sessionId = "sessionId"
    private var viewModel: SessionDetailsViewModel!
    private var api: MockWWDCastAPI!
    private var delegate: MockSessionsSearchViewModelDelegate!
    private var disposeBag: DisposeBag!

    override func setUp() {
        self.api = MockWWDCastAPI()
        self.disposeBag = DisposeBag()
    }

    /// Test that video playback starts for specified session
    func testSessionPlaybackStarts() {
        // GIVEN
        let expectation = self.expectation(description: "didStartPlaying")
        self.api.sessionObservable = { sessionId in
            return Observable.just(Session.dummySession)
        }
        let devices = [GoogleCastDevice(name: "#1", id: "1"), GoogleCastDevice(name: "#2", id: "2")]
        let selectedDevice = 1
        self.api.devicesObservable = Observable.just(devices)
        self.api.playObservable = { session, device in
            XCTAssertEqual(session.uniqueId, Session.dummySession.uniqueId)
            XCTAssertEqual(device.id, devices[selectedDevice].id)
            expectation.fulfill()
            return Observable.empty()
        }
        self.viewModel = SessionDetailsViewModel(sessionId: self.sessionId, api: self.api)

        // WHEN
        self.viewModel.startPlaybackOnDevice(at: selectedDevice)

        // THEN
        self.waitForExpectations(timeout: 1.0, handler: nil)
    }

    /// Test that error observable emits a new value when video playback fails
    func testSessionPlaybackFails() {
        // GIVEN
        let expectation = self.expectation(description: "didFailPlaying")
        self.api.sessionObservable = { sessionId in
            return Observable.just(Session.dummySession)
        }
        let devices = [GoogleCastDevice(name: "#1", id: "1"), GoogleCastDevice(name: "#2", id: "2")]
        let selectedDevice = 1
        self.api.devicesObservable = Observable.just(devices)
        self.api.playObservable = { _ in
            return Observable.error(GoogleCastServiceError.playbackError)
        }
        self.viewModel = SessionDetailsViewModel(sessionId: self.sessionId, api: self.api)
        self.viewModel.error.asObservable().subscribe(onNext: { _ in
            expectation.fulfill()
        }).addDisposableTo(self.disposeBag)

        // WHEN
        self.viewModel.startPlaybackOnDevice(at: selectedDevice)

        // THEN
        self.waitForExpectations(timeout: 1.0, handler: nil)
    }

    /// Test that session Observable emits a value when the user toggles a favorite session
    func testFavoriteSessionToggle() {
        // GIVEN
        let expectation = self.expectation(description: "didToggleFavorite")
        self.api.sessionObservable = { sessionId in
            return Observable.just(Session.dummySession)
        }
        self.api.toggleObservable = { session in
            return Observable.just(Session.favoriteSession)
        }
        self.viewModel = SessionDetailsViewModel(sessionId: self.sessionId, api: self.api)
        self.viewModel.session.asObservable().skip(1).subscribe(onNext: { viewModel in
            XCTAssertTrue(viewModel!.favorite)
            expectation.fulfill()
        }).addDisposableTo(self.disposeBag)

        // WHEN
        self.viewModel.toggleFavorite()

        // THEN
        self.waitForExpectations(timeout: 1.0, handler: nil)
    }
}
