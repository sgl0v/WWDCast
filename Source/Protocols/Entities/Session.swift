//
//  Session.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 04/07/16.
//  Copyright © 2016 Maksym Shcheglov. All rights reserved.
//

import Foundation

protocol Session {
    var uniqueId: String { get }
    var id: Int { get }
    var year: Int { get }
    var date: NSDate? { get }
    var track: String { get }
    var focus: String { get }
    var title: String { get }
    var summary: String { get }
    var videoURL: String { get }
    var hdVideoURL: String { get }
    var slidesURL: String { get }
    var shelfImageURL: String { get }
}