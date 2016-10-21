//
//  CacheService.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 21/10/2016.
//  Copyright © 2016 Maksym Shcheglov. All rights reserved.
//

import Foundation

protocol CacheService: class {
    
    func objectForKey(key: String) -> AnyObject?
    func setObject(obj: AnyObject, forKey key: String)
    func removeObject(forKey key: String)
    
}
