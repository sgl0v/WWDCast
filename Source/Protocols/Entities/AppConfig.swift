//
//  AppConfig.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 04/07/16.
//  Copyright © 2016 Maksym Shcheglov. All rights reserved.
//

import Foundation

protocol AppConfig {
    var sessionsURL: NSURL { get }
    var videosURL: NSURL { get }
    var isWWDCWeek: Bool { get }
}
