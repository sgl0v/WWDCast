//
//  MockSessionsSearchViewModelDelegate.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 01/03/2017.
//  Copyright © 2017 Maksym Shcheglov. All rights reserved.
//

import UIKit
@testable import WWDCast

class MockSessionsSearchViewModelDelegate: SessionsSearchViewModelDelegate {

    typealias FilterHandler = (SessionsSearchViewModelProtocol, Filter, @escaping (Filter) -> Void) -> Void
    typealias DetailsHandler = (SessionsSearchViewModelProtocol, String) -> Void

    var filterHandler: FilterHandler?
    var detailsHandler: DetailsHandler?

    func sessionsSearchViewModel(_ viewModel: SessionsSearchViewModelProtocol, wantsToShow filter: Filter, completion: @escaping (Filter) -> Void) {
        guard let handler = self.filterHandler else {
            fatalError("Not implemented")
        }
        return handler(viewModel, filter, completion)
    }

    func sessionsSearchViewModel(_ viewModel: SessionsSearchViewModelProtocol, wantsToShowSessionDetailsWith sessionId: String) {
        guard let handler = self.detailsHandler else {
            fatalError("Not implemented")
        }
        return handler(viewModel, sessionId)
    }

}
