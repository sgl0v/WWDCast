//
//  GoogleCastDeviceImpl.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 28/09/2016.
//  Copyright © 2016 Maksym Shcheglov. All rights reserved.
//

import Foundation

struct GoogleCastDeviceImpl: GoogleCastDevice {
    var name: String
    var id: String
    
    var description: String {
        return name
    }
}
