//
//  SessionItemViewModel+Tests.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 02/03/2017.
//  Copyright © 2017 Maksym Shcheglov. All rights reserved.
//

import Foundation
import RxSwift
import UIKit
@testable import WWDCast

extension SessionItemViewModel {

    static var dummyItem: SessionItemViewModel {
        let thumbnailImage = UIImage()
        let thumbnail = Observable.just(thumbnailImage)
        return SessionItemViewModel(id: "uniqueID", title: "title", subtitle: "subtitle", summary: "summary", thumbnail: thumbnail, favorite: false)
    }

}
