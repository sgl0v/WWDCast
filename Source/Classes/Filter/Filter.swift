//
//  Filter.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 14/08/2016.
//  Copyright © 2016 Maksym Shcheglov. All rights reserved.
//

import Foundation

struct Filter {
    var query: String = ""
    var year = [Int]()
    var platforms = [Platform]()
    var tracks = [Track]()
}
