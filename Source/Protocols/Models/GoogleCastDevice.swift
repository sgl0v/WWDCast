//
//  GoogleCastDevice.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 28/09/2016.
//  Copyright © 2016 Maksym Shcheglov. All rights reserved.
//

import Foundation

protocol GoogleCastDevice: CustomStringConvertible {
    var name: String { get }
    var id: String { get }
}
