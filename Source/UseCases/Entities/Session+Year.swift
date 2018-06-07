//
//  Session+Year.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 05/06/2018.
//  Copyright © 2018 Maksym Shcheglov. All rights reserved.
//

import Foundation

extension Session {
    enum Year: Int {
        case _2013 = 2013, _2014 = 2014, _2015 = 2015, _2016 = 2016, _2017 = 2017, _2018 = 2018

        static let all: [Year] = [._2018, ._2017, ._2016, ._2015, ._2014, ._2013]
    }
}

extension Session.Year: CustomStringConvertible {

    var description: String {
        return "\(self.rawValue)"
    }
}
