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

final class RxGCKSessionManagerListenerProxy: DelegateProxy<GCKSessionManager, GCKSessionManagerListener>, GCKSessionManagerListener, DelegateProxyType {

    // Declare a global var to produce a unique address as the assoc object handle
    private static var associatedObjectHandle: UInt8 = 0

    public init(sessionManager: GCKSessionManager) {
        super.init(parentObject: sessionManager, delegateProxy: RxGCKSessionManagerListenerProxy.self)
    }

    static func registerKnownImplementations() {
        self.register { RxGCKSessionManagerListenerProxy(sessionManager: $0) }
    }

    //We need a way to read the current delegate
    static func currentDelegate(for object: GCKSessionManager) -> GCKSessionManagerListener? {
        guard let listener = objc_getAssociatedObject(object, &associatedObjectHandle) as? GCKSessionManagerListener else {
            return nil
        }
        return listener
    }

    //We need a way to set the current delegate
    static func setCurrentDelegate(_ delegate: GCKSessionManagerListener?, to object: GCKSessionManager) {
        if let listener = delegate {
            objc_setAssociatedObject(object, &associatedObjectHandle, delegate, objc_AssociationPolicy.OBJC_ASSOCIATION_ASSIGN)
            object.add(listener)
        } else if let listener = objc_getAssociatedObject(object, &associatedObjectHandle) as? GCKSessionManagerListener {
            object.remove(listener)
        }
    }
}

// swiftlint:disable force_cast

extension Reactive where Base: GCKSessionManager {

    var delegate: DelegateProxy<GCKSessionManager, GCKSessionManagerListener> {
        return RxGCKSessionManagerListenerProxy.proxy(for: base)
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

// swiftlint:enable force_cast
