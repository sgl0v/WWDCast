//
//  RxGCKDeviceManagerDelegateProxy.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 13/08/2016.
//  Copyright © 2016 Maksym Shcheglov. All rights reserved.
//

import Foundation
import GoogleCast
import RxSwift
import RxCocoa

final class RxGCKDeviceManagerDelegateProxy: DelegateProxy, GCKDeviceManagerDelegate, DelegateProxyType {
    //We need a way to read the current delegate
    static func currentDelegateFor(object: AnyObject) -> AnyObject? {
        let deviceManager: GCKDeviceManager = object as! GCKDeviceManager
        return deviceManager.delegate
    }
    //We need a way to set the current delegate
    static func setCurrentDelegate(delegate: AnyObject?, toObject object: AnyObject) {
        let deviceManager: GCKDeviceManager = object as! GCKDeviceManager
        deviceManager.delegate = delegate as? GCKDeviceManagerDelegate
    }
}

extension GCKDeviceManager {
    
    var rx_delegate: DelegateProxy {
        return RxGCKDeviceManagerDelegateProxy.proxyForObject(self)
    }
    
    var rx_didConnect: Observable<GCKDeviceManager> {
        return self.rx_delegate.observe(#selector(GCKDeviceManagerDelegate.deviceManagerDidConnect(_:)))
            .map { params in params.first as! GCKDeviceManager }
    }
    
    var rx_didFailToConnect: Observable<NSError> {
        return self.rx_delegate.observe(#selector(GCKDeviceManagerDelegate.deviceManager(_:didFailToConnectWithError:)))
            .map { params in params.last as! NSError }
    }
    
    var rx_didConnectToCastApplication: Observable<(GCKApplicationMetadata, String, Bool)> {
        return rx_delegate.observe(#selector(GCKDeviceManagerDelegate.deviceManager(_:didConnectToCastApplication:sessionID:launchedApplication:)))
            .map { params in (params[1] as! GCKApplicationMetadata, params[2] as! String, (params[3] as! NSNumber).boolValue) }
    }
    
    var didFailToConnectToApplication: Observable<NSError> {
        return rx_delegate.observe(#selector(GCKDeviceManagerDelegate.deviceManager(_:didFailToConnectToApplicationWithError:)))
            .map { params in params.last as! NSError }
    }
    
}
