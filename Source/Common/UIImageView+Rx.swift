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

    var imageURL: AnyObserver<(URL, UIImage?)> {
        let completion: SDWebImage.SDWebImageCompletionBlock = { [weak base] _ in
            let transition = CATransition()
            transition.duration = 0.3
            transition.timingFunction =
                CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            base?.layer.add(transition, forKey: kCATransition)
        }
        return AnyObserver { [weak base] event in
            switch event {
            case .next(let url, nil):
                base?.sd_setImage(with: url, completed: completion)
            case .next(let url, let placeholderImage):
                base?.sd_setImage(with: url, placeholderImage: placeholderImage, options: [], completed: completion)
            default:
                break
            }

        }
    }
}
