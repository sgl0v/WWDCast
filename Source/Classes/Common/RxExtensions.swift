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

infix operator <->

infix operator <~

infix operator ~>

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
    
    return Disposables.create(bindToUIDisposable, bindToVariable)
}

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

extension UIAlertController {
    enum Selection {
        case action(UInt), cancel
    }
    
    static func promptFor<Action : CustomStringConvertible>(_ title: String?, message: String?, cancelAction: Action, actions: [Action]) -> (UIViewController) -> Observable<Action> {
        return { viewController in
            return Observable.create { observer in
                let alertView = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
                alertView.addAction(UIAlertAction(title: cancelAction.description, style: .cancel) { _ in
                    observer.onNext(cancelAction)
                    observer.onCompleted()
                })
                
                for action in actions {
                    alertView.addAction(UIAlertAction(title: action.description, style: .`default`) { _ in
                        observer.onNext(action)
                        observer.onCompleted()
                    })
                }
                
                viewController.present(alertView, animated: true, completion: nil)
                
                return Disposables.create {
                    alertView.dismiss(animated: false, completion: nil)
                }
            }
        }
    }
}
