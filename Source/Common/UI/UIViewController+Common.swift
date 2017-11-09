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
    func showAlert(with title: String?, message: String) {
        let alertView = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertView.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "OK button title"), style: .cancel) { _ in
        })
        self.present(alertView, animated: true, completion: nil)
    }

    /// Presents an alert dialog with specified title, message and actions
    func showAlert<Action: CustomStringConvertible>(with title: String?, message: String?, cancelAction: Action, actions: [Action]) -> Observable<UIAlertController.Selection> {
        let alertView = UIAlertController.promptFor(title, message: message, cancelAction: cancelAction, actions: actions)
        return alertView(self)
    }

}
