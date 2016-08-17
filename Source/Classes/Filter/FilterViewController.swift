//
//  FilterViewController.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 13/08/2016.
//  Copyright © 2016 Maksym Shcheglov. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class FilterViewController: TableViewController<SessionViewModels, SessionTableViewCell> {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureUI()
        self.setupBindings()
    }
    
    // MARK - Private
    
    private func setupBindings() {
        // dismiss keyboard on scroll
        self.navigationItem.leftBarButtonItem!.rx_tap.subscribeNext({
            self.dismissViewControllerAnimated(true, completion: nil)
        }).addDisposableTo(self.disposeBag)
        self.navigationItem.leftBarButtonItem!.rx_tap.subscribeNext({
            self.dismissViewControllerAnimated(true, completion: nil)
        }).addDisposableTo(self.disposeBag)
    }

    private func configureUI() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.castBarButtonItem()
        self.navigationItem.leftBarButtonItem = self.barButton(withStyle: .Cancel)
        self.navigationItem.rightBarButtonItem = self.barButton(withStyle: .Done)
    }
    
    private func barButton(withStyle style: UIBarButtonSystemItem) -> UIBarButtonItem {
        let button = UIBarButtonItem(barButtonSystemItem: style, target: nil, action: nil)
        button.tintColor = UIColor.blackColor()
        return button
    }

}
