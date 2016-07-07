//
//  SessionsSearchView.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 04/07/16.
//  Copyright © 2016 Maksym Shcheglov. All rights reserved.
//

import Foundation

protocol SessionsSearchView: class {
    func setTitle(title: String)
    func showSessions(sessions: [SessionViewModel])
}
