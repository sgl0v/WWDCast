//
//  RxExtensions.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 05/07/16.
//  Copyright © 2016 Maksym Shcheglov. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import SDWebImage

// One way binding operator

infix operator <-> {
}

infix operator <~ {
}

infix operator ~> {
}

// Two way binding operator between control property and variable, that's all it takes {

func <-> <T>(property: ControlProperty<T>, variable: Variable<T>) -> Disposable {
    let bindToUIDisposable = variable.asObservable()
        .bindTo(property)
    let bindToVariable = property
        .subscribe(onNext: { n in
            variable.value = n
            },
                   onCompleted: {
                    bindToUIDisposable.dispose()
        })
    
    return StableCompositeDisposable.create(bindToUIDisposable, bindToVariable)
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

extension UIAlertController {
    enum Selection {
        case Action(UInt), Cancel
    }
    
    static func promptFor<Action : CustomStringConvertible>(title: String?, message: String?, cancelAction: Action, actions: [Action]) -> UIViewController -> Observable<Action> {
        return { viewController in
            return Observable.create { observer in
                let alertView = UIAlertController(title: title, message: message, preferredStyle: .ActionSheet)
                alertView.addAction(UIAlertAction(title: cancelAction.description, style: .Cancel) { _ in
                    observer.onNext(cancelAction)
                    observer.onCompleted()
                })
                
                for action in actions {
                    alertView.addAction(UIAlertAction(title: action.description, style: .Default) { _ in
                        observer.onNext(action)
                        observer.onCompleted()
                    })
                }
                
                viewController.presentViewController(alertView, animated: true, completion: nil)
                
                return AnonymousDisposable {
                    alertView.dismissViewControllerAnimated(false, completion: nil)
                }
            }
        }
    }
}
