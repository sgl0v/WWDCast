//
//  Session+Tests.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 02/03/2017.
//  Copyright © 2017 Maksym Shcheglov. All rights reserved.
//

import Foundation
@testable import WWDCast

extension Session {


    static var dummySession = session(favorite: false)

    static var favoriteSession = session(favorite: true)

    private static func session(favorite: Bool) -> Session {
        let thumbnail = "http://devstreaming.apple.com/videos/wwdc/2016/210e4481b1cnwor4n1q/210/images/210_734x413.jpg"
        let video = "http://devstreaming.apple.com/videos/wwdc/2016/210e4481b1cnwor4n1q/210/210_hd_mastering_uikit_on_tvos.mp4"
        guard let thumbnailUrl = URL(string: thumbnail),
            let videoUrl = URL(string: video) else {
                fatalError("Failed to create url from string: \(thumbnail).")
        }

        return Session(id: 210, year: ._2016, track: .all, platforms: [.tvOS], title: "Mastering UIKit on tvOS", summary: "Learn how to make your tvOS interface more dynamic, intuitive, and high-performing with tips and tricks learned in this session.", video: videoUrl, captions: nil, thumbnail: thumbnailUrl, favorite: favorite)

    }
}
