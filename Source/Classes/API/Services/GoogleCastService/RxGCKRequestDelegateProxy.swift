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

final class RxGCKRequestDelegateProxy: DelegateProxy, GCKRequestDelegate, DelegateProxyType {

    //We need a way to read the current delegate
    static func currentDelegateFor(_ object: AnyObject) -> AnyObject? {
        guard let request = object as? GCKRequest else {
            return nil
        }
        return request.delegate
    }

    //We need a way to set the current delegate
    static func setCurrentDelegate(_ delegate: AnyObject?, toObject object: AnyObject) {
        guard let request = object as? GCKRequest,
            let delegate = delegate as? GCKRequestDelegate else {
                return
        }
        request.delegate = delegate
    }
}

// swiftlint:disable weak_delegate force_cast

extension Reactive where Base: GCKRequest {

    var delegate: DelegateProxy {
        return RxGCKRequestDelegateProxy.proxyForObject(base)
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

// swiftlint:enable weak_delegate force_cast
