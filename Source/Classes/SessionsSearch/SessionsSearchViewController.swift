//
//  ViewController.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 04/07/16.
//  Copyright © 2016 Maksym Shcheglov. All rights reserved.
//

import UIKit

class SessionsSearchViewController: UITableViewController {
    var presenter: SessionsSearchPresenter!

    convenience init() {
        self.init(nibName: "SessionsSearchViewController", bundle: NSBundle.mainBundle())
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.presenter.updateView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension SessionsSearchViewController: SessionsSearchView {

}
