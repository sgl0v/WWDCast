//
//  UIViewController+Common.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 16/02/2017.
//  Copyright © 2017 Maksym Shcheglov. All rights reserved.
//

import UIKit
import RxSwift

extension UIViewController {

    /// Presents an alert with specified title and message
    func showAlert(for error: Error) {
        let title = NSLocalizedString("Error", comment: "Error Alert Title")
        let alert = UIAlertController(title: title, message: "\(error)", preferredStyle: .alert)
        let action = UIAlertAction(title: NSLocalizedString("Dismiss", comment: "Dimiss button title"),
                                   style: UIAlertActionStyle.cancel,
                                   handler: nil)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }

    /// Presents an alert with specified title and message
    func showAlert(with title: String?, message: String) {
        let alertView = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertView.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "OK button title"), style: .cancel, handler: nil))
        self.present(alertView, animated: true, completion: nil)
    }

    /// Presents an alert dialog with specified title, message and actions
    func showAlert<Action: CustomStringConvertible>(with title: String?, message: String?, cancelAction: Action, actions: [Action]) -> Observable<Int> {
        let alertView = UIAlertController.promptFor(title, message: message, cancelAction: cancelAction, actions: actions)
        return alertView(self).flatMap({ selection -> Observable<Int> in
            switch selection {
            case .action(let idx):
                return Observable.just(idx)
            case .cancel:
                return Observable.empty()
            }
        })
    }

}
