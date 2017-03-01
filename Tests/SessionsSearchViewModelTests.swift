//
//  SessionsSearchViewModelTests.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 01/03/2017.
//  Copyright © 2017 Maksym Shcheglov. All rights reserved.
//

import XCTest
@testable import WWDCast

class SessionsSearchViewModelTests: XCTestCase {

    private var viewModel: SessionsSearchViewModel!
    private var api: WWDCastAPIProtocol!
    private var delegate: SessionsSearchViewModelDelegate!

    override func setUp() {
        self.api = MockWWDCastAPI()
        self.delegate = MockSessionsSearchViewModelDelegate()
        self.viewModel = SessionsSearchViewModel(api: self.api, delegate: self.delegate)
    }

}
