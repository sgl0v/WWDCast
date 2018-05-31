//
//  FlowCoordinator.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 18/02/2017.
//  Copyright © 2017 Maksym Shcheglov. All rights reserved.
//

import UIKit

/// A `FlowCoordinator` takes responsibility about coordinating view controllers and driving the flow in the application.
protocol FlowCoordinator: class {

    /// Stars the flow
    func start()
}
