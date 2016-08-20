//
//  Filter.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 14/08/2016.
//  Copyright © 2016 Maksym Shcheglov. All rights reserved.
//

import Foundation
import RxSwift

struct Filter: CustomStringConvertible {
    var query: String = ""
    var year = [Int]()
    var platforms = [Platform]()
    var tracks = [Track]()
    
    // MARK: CustomStringConvertible
    var description : String {
        return "query='\(query)' year='\(year)' platforms='\(platforms)' tracks='\(tracks)'"
    }

}
