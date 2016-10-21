//
//  CacheServiceImpl.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 21/10/2016.
//  Copyright © 2016 Maksym Shcheglov. All rights reserved.
//

import Foundation

class CacheServiceImpl: CacheService {
    
    func objectForKey(key: String) -> AnyObject? {
        return NSUserDefaults.standardUserDefaults().objectForKey(key)
    }
    
    func setObject(obj: AnyObject, forKey key: String) {
        NSUserDefaults.standardUserDefaults().setObject(obj, forKey: key)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    func removeObject(forKey key: String) {
        NSUserDefaults.standardUserDefaults().removeObjectForKey(key)
        NSUserDefaults.standardUserDefaults().synchronize()
    }

}