//
//  ViewController.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 04/07/16.
//  Copyright © 2016 Maksym Shcheglov. All rights reserved.
//

import UIKit

class SessionsSearchViewController: TableViewController<SessionViewModel, SessionTableViewCell> {
    var presenter: SessionsSearchPresenter!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.clearsSelectionOnViewWillAppear = true
        self.presenter.updateView()
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.presenter.selectItem(atIndex: indexPath.row)
    }
//
//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//        // Dispose of any resources that can be recreated.
//    }

}

extension SessionsSearchViewController: SessionsSearchView {

    func showSessions(sessions: [SessionViewModel]) {
        self.data = sessions
    }

    func setTitle(title: String) {
        self.title = title
    }

}
