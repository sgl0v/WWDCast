//
//  UIImageView+Rx.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 29/11/2016.
//  Copyright © 2016 Maksym Shcheglov. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import SDWebImage

extension Reactive where Base: UIImageView {
    
    var imageURL: AnyObserver<URL> {
        return AnyObserver { [weak base] event in
            switch event {
            case .next(let value):
                base?.image = nil
                base?.sd_setImage(with: value, completed: { [weak base] _ in
                    let transition = CATransition()
                    transition.duration = 0.3
                    transition.timingFunction =
                        CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
                    base?.layer.add(transition, forKey: kCATransition)
                })
            default:
                break
            }
            
        }
    }
}
