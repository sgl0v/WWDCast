//
//  ModuleFactory.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 06/07/16.
//  Copyright © 2016 Maksym Shcheglov. All rights reserved.
//

import UIKit

protocol WWDCastAssembly: class {
    func sessionsSearchModule() -> UIViewController
    func sessionDetailsModule(withId Id: String) -> UIViewController
}
