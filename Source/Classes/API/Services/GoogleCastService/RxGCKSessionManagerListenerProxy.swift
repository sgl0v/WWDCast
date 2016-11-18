//
//  RxGCKSessionManagerListenerProxy.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 18/11/2016.
//  Copyright © 2016 Maksym Shcheglov. All rights reserved.
//

import Foundation
import GoogleCast
import RxSwift
import RxCocoa
import ObjectiveC

final class RxGCKSessionManagerListenerProxy: DelegateProxy, GCKSessionManagerListener, DelegateProxyType {
    
    // Declare a global var to produce a unique address as the assoc object handle
    static var associatedObjectHandle: UInt8 = 0
    
    //We need a way to read the current delegate
    static func currentDelegateFor(_ object: AnyObject) -> AnyObject? {
        guard let sessionManager = object as? GCKSessionManager,
            let listener = objc_getAssociatedObject(sessionManager, &associatedObjectHandle) as? GCKSessionManagerListener else {
                return nil
        }
        return listener
    }
    
    //We need a way to set the current delegate
    static func setCurrentDelegate(_ delegate: AnyObject?, toObject object: AnyObject) {
        guard let listener = delegate as? GCKSessionManagerListener,
            let sessionManager = object as? GCKSessionManager else {
                return
        }
        objc_setAssociatedObject(sessionManager, &associatedObjectHandle, listener, objc_AssociationPolicy.OBJC_ASSOCIATION_ASSIGN)
        sessionManager.add(listener)
    }
}

extension Reactive where Base: GCKSessionManager {
    
    var delegate: DelegateProxy {
        return RxGCKSessionManagerListenerProxy.proxyForObject(base)
    }
    
    var didStart: Observable<GCKSessionManager> {
        return self.delegate.methodInvoked(#selector(GCKSessionManagerListener.sessionManager(_:didStart:)))
            .map { params in params.first as! GCKSessionManager }
    }
    
    var didFailToStart: Observable<NSError> {
        return self.delegate.methodInvoked(#selector(GCKSessionManagerListener.sessionManager(_:didFailToStart:withError:)))
            .map { params in params.last as! NSError }
    }
    
}
