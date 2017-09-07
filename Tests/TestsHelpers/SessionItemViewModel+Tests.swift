//
//  SessionItemViewModel+Tests.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 02/03/2017.
//  Copyright © 2017 Maksym Shcheglov. All rights reserved.
//

import Foundation
@testable import WWDCast

extension SessionItemViewModel {

    static var dummyItem: SessionItemViewModel {
        let thumbnail = "http://devstreaming.apple.com/videos/wwdc/thumbnails/d20ft1ql/2014/236/236_shelf.jpg"
        guard let thumbnailUrl = URL(string: thumbnail) else {
            fatalError("Failed to create url from string: \(thumbnail).")
        }
        return SessionItemViewModel(id: "uniqueID", title: "title", subtitle: "subtitle", summary: "summary", thumbnailURL: thumbnailUrl, thumbnailPlaceholder: #imageLiteral(resourceName: "wwdc"), favorite: false)
    }

}
