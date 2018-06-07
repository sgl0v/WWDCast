//
//  RxGCKDiscoveryManagerListener.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 06/04/2018.
//  Copyright © 2018 Maksym Shcheglov. All rights reserved.
//

import Foundation
import GoogleCast
import RxSwift
import RxCocoa

final class RxGCKDiscoveryManagerListenerProxy: DelegateProxy<GCKDiscoveryManager, GCKDiscoveryManagerListener>, GCKDiscoveryManagerListener, DelegateProxyType {

    // Declare a global var to produce a unique address as the assoc object handle
    private static var associatedObjectHandle: UInt8 = 0

    public init(discoveryManager: GCKDiscoveryManager) {
        super.init(parentObject: discoveryManager, delegateProxy: RxGCKDiscoveryManagerListenerProxy.self)
    }

    static func registerKnownImplementations() {
        self.register { RxGCKDiscoveryManagerListenerProxy(discoveryManager: $0) }
    }

    //We need a way to read the current delegate
    static func currentDelegate(for object: GCKDiscoveryManager) -> GCKDiscoveryManagerListener? {
        guard let listener = objc_getAssociatedObject(object, &associatedObjectHandle) as? GCKDiscoveryManagerListener else {
            return nil
        }
        return listener
    }

    //We need a way to set the current delegate
    static func setCurrentDelegate(_ delegate: GCKDiscoveryManagerListener?, to object: GCKDiscoveryManager) {
        if let listener = delegate {
            objc_setAssociatedObject(object, &associatedObjectHandle, delegate, objc_AssociationPolicy.OBJC_ASSOCIATION_ASSIGN)
            object.add(listener)
        } else if let listener = objc_getAssociatedObject(object, &associatedObjectHandle) as? GCKDiscoveryManagerListener {
            object.remove(listener)
        }
    }
}

extension Reactive where Base: GCKDiscoveryManager {

    var delegate: DelegateProxy<GCKDiscoveryManager, GCKDiscoveryManagerListener> {
        return RxGCKDiscoveryManagerListenerProxy.proxy(for: base)
    }

    var didUpdateDeviceList: Observable<[GCKDevice]> {
        return self.delegate.methodInvoked(#selector(GCKDiscoveryManagerListener.didUpdateDeviceList)).map { _ in
            return (0..<self.base.deviceCount).map({ idx in
                return self.base.device(at: idx)
            })
        }
    }

}
