//
//  GoogleCastMedia.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 18/11/2016.
//  Copyright © 2016 Maksym Shcheglov. All rights reserved.
//

import Foundation

struct GoogleCastMedia {
    let id: Int
    let title: String
    let subtitle: String
    let thumbnail: URL
    let video: String
    let captions: String?
}

extension GoogleCastMedia: Hashable {
    
    var hashValue: Int {
        return self.id.hashValue
    }
}

func ==(lhs: GoogleCastMedia, rhs: GoogleCastMedia) -> Bool {
    return lhs.id == rhs.id
}
