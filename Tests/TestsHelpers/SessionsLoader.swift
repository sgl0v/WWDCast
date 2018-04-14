//
//  Session+Tests.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 02/03/2017.
//  Copyright © 2017 Maksym Shcheglov. All rights reserved.
//

import Foundation
import SwiftyJSON
@testable import WWDCast

class SessionsLoader {

    static func sessionsFromFile(withName name: String) -> [Session] {
        guard let path = Bundle(for: SessionsLoader.self).path(forResource: name, ofType: nil),
            let data = try? Data(contentsOf: URL(fileURLWithPath: path)),
            let sessions = try? SessionsBuilder.build(from: data) else {
                fatalError("Failed to load sessions from file with name: \(name).")
        }
        return sessions
    }

}
