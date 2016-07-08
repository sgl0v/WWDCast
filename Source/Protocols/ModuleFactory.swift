//
//  ModuleFactory.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 06/07/16.
//  Copyright © 2016 Maksym Shcheglov. All rights reserved.
//

import UIKit

protocol ModuleFactory {
    static func sessionsSearchModule() -> UIViewController
    static func sessionDetailsModule() -> UIViewController
}
