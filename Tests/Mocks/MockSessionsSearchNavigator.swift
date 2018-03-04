//
//  MockSessionsSearchNavigator.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 01/03/2017.
//  Copyright © 2017 Maksym Shcheglov. All rights reserved.
//

import UIKit
@testable import WWDCast

class MockSessionsSearchNavigator: SessionsSearchNavigator {

    typealias FilterHandler = () -> Void
    typealias DetailsHandler = (String) -> Void

    var filterHandler: FilterHandler?
    var detailsHandler: DetailsHandler?

    func showFilter() {
        guard let handler = self.filterHandler else {
            fatalError("Not implemented")
        }
        return handler()
    }

    func showDetails(forSession sessionId: String) {
        guard let handler = self.detailsHandler else {
            fatalError("Not implemented")
        }
        return handler(sessionId)
    }

}
