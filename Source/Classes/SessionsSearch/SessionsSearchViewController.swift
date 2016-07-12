//
//  ViewController.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 04/07/16.
//  Copyright © 2016 Maksym Shcheglov. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class SessionsSearchViewController: TableViewController<SessionViewModels, SessionTableViewCell> {
    var presenter: SessionsSearchPresenter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.clearsSelectionOnViewWillAppear = true
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 100
        self.tableView.delegate = nil
        self.tableView.dataSource = nil

        self.tableView.rx_itemSelected.map({ indexPath in return indexPath.row })
            .bindTo(self.presenter.itemSelected)
            .addDisposableTo(self.disposeBag)

        self.presenter.updateView.onNext()
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

//        self.navigationItem.rightBarButtonItems = UIBarButtonItem(customView: CastButton())
//        // Assign ourselves as delegate ONLY in viewWillAppear of a view controller.
//        CastDeviceController *controller = [CastDeviceController sharedInstance];
//        controller.delegate = self;
//
//        UIBarButtonItem *item = [controller queueItemForController:self];
//        self.navigationItem.rightBarButtonItems = @[item];

    }

//
//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//        // Dispose of any resources that can be recreated.
//    }

}

extension SessionsSearchViewController: SessionsSearchView {

    var showSessions: AnyObserver<[SessionViewModels]> {
        return AnyObserver {[unowned self] event in
            guard case .Next(let sessions) = event else {
                return
            }
            Observable.just(sessions).bindTo(self.tableView.rx_itemsWithDataSource(self.source)).addDisposableTo(self.disposeBag)
        }
    }

    var titleText: AnyObserver<String> {
        return self.rx_title
    }

}
