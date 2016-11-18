//
//  GoogleCastDeviceImpl.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 28/09/2016.
//  Copyright © 2016 Maksym Shcheglov. All rights reserved.
//

import Foundation

struct GoogleCastDevice {
    var name: String
    var id: String
}

extension GoogleCastDevice: CustomStringConvertible {

    var description: String {
        return name
    }

}

extension GoogleCastDevice: Hashable {
    
    var hashValue: Int {
        return self.id.hashValue
    }
}

func ==(lhs: GoogleCastDevice, rhs: GoogleCastDevice) -> Bool {
    return lhs.id == rhs.id
}
