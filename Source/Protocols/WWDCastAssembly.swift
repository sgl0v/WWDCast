//
//  ModuleFactory.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 06/07/16.
//  Copyright © 2016 Maksym Shcheglov. All rights reserved.
//

import UIKit

protocol WWDCastAssembly: class {
    func sessionsSearchController() -> UIViewController
    func sessionDetailsController(_ sessionId: String) -> UIViewController
    func filterController(_ filter: Filter, completion: @escaping FilterModuleCompletion) -> UIViewController
}
