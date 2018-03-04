//
//  MockFavoriteSessionsViewModelDelegate.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 02/03/2017.
//  Copyright © 2017 Maksym Shcheglov. All rights reserved.
//

import UIKit
@testable import WWDCast

class MockFavoriteSessionsNavigator: FavoriteSessionsNavigator {

    typealias DetailsHandler = (String) -> Void

    var detailsHandler: DetailsHandler?

    func showDetails(forSession sessionId: String) {
        guard let handler = self.detailsHandler else {
            fatalError("Not implemented")
        }
        return handler(sessionId)
    }
}
