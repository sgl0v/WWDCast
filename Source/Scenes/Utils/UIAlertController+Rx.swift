//
//  UIAlertController+Rx.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 29/11/2016.
//  Copyright © 2016 Maksym Shcheglov. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

extension UIAlertController {
    enum Selection {
        case action(Int), cancel
    }

    static func promptFor<Action: CustomStringConvertible>(_ title: String?, message: String?, cancelAction: Action, actions: [Action]) -> (UIViewController) -> Observable<Selection> {
        return { viewController in
            return Observable.create { observer in
                let alertView = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
                alertView.addAction(UIAlertAction(title: cancelAction.description, style: .cancel) { _ in
                    observer.onNext(.cancel)
                    observer.onCompleted()
                })

                for (idx, action) in actions.enumerated() {
                    alertView.addAction(UIAlertAction(title: action.description, style: .`default`) { _ in
                        observer.onNext(.action(idx))
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
