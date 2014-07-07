//
//  RxExtensions.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 05/07/16.
//  Copyright © 2016 Maksym Shcheglov. All rights reserved.
//

import Foundation
import RxSwift
import Alamofire
import SDWebImage

func rx_request(method: Alamofire.Method, _ URLString: URLStringConvertible) -> Observable<AnyObject> {
    return Observable<AnyObject>.create({ (observer) -> Disposable in
        let request = Alamofire.request(method, URLString)
            .responseJSON(completionHandler: { (firedResponse) -> Void in
                if let value = firedResponse.result.value {
                    observer.onNext(value)
                    observer.onCompleted()
                } else if let error = firedResponse.result.error {
                    observer.onError(error)
                }
            })
        return AnonymousDisposable {
            request.cancel()
        }
    })
}


extension UIImageView {
    var rx_imageURL: AnyObserver<NSURL> {
        return AnyObserver { [weak self] event in
            switch event {
            case .Next(let value):
                self?.image = nil
                self?.sd_setImageWithURL(value, completed: { [weak self] _ in
                    let transition = CATransition()
                    transition.duration = 0.3
                    transition.timingFunction =
                        CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
                    self?.layer.addAnimation(transition, forKey: kCATransition)
                    })
            default:
                break
            }
            
        }
    }
}
