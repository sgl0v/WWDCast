//
//  SessionsSearchPresenter.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 04/07/16.
//  Copyright © 2016 Maksym Shcheglov. All rights reserved.
//

import Foundation

protocol SessionsSearchPresenter: class {
    func updateView()
    func selectItem(atIndex index: Int)
}
