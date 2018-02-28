//
//  RxGCKRequestDelegateProxy.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 18/11/2016.
//  Copyright © 2016 Maksym Shcheglov. All rights reserved.
//

import Foundation
import GoogleCast
import RxSwift
import RxCocoa

final class RxGCKRequestDelegateProxy: DelegateProxy<GCKRequest, GCKRequestDelegate>, GCKRequestDelegate, DelegateProxyType {

    public init(request: GCKRequest) {
        super.init(parentObject: request, delegateProxy: RxGCKRequestDelegateProxy.self)
    }

    static func registerKnownImplementations() {
        self.register { RxGCKRequestDelegateProxy(request: $0) }
    }

    //We need a way to read the current delegate
    static func currentDelegate(for object: GCKRequest) -> GCKRequestDelegate? {
        return object.delegate
    }

    //We need a way to set the current delegate
    static func setCurrentDelegate(_ delegate: GCKRequestDelegate?, to object: GCKRequest) {
        object.delegate = delegate
    }

}

// swiftlint:disable force_cast

extension Reactive where Base: GCKRequest {

    var delegate: DelegateProxy<GCKRequest, GCKRequestDelegate> {
        return RxGCKRequestDelegateProxy.proxy(for: base)
    }

    var didComplete: Observable<GCKRequest> {
        return self.delegate.methodInvoked(#selector(GCKRequestDelegate.requestDidComplete(_:)))
            .map { params in params.first as! GCKRequest }
    }

    var didFailWithError: Observable<NSError> {
        return self.delegate.methodInvoked(#selector(GCKRequestDelegate.request(_:didFailWithError:)))
            .map { params in params.last as! NSError }
    }

    var didAbort: Observable<GCKRequestAbortReason> {
        return self.delegate.methodInvoked(#selector(GCKRequestDelegate.request(_:didAbortWith:)))
            .map { params in params.last as! GCKRequestAbortReason }
    }
}

// swiftlint:enable force_cast
