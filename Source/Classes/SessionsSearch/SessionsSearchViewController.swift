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
    
    private lazy var searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.dimsBackgroundDuringPresentation = false
        return searchController
    }()
    
    private var searchBar: UISearchBar {
        return self.searchController.searchBar
    }
    
    var presenter: SessionsSearchPresenter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = castBarButtonItem()

        configureTableView()
        
//        self.searchBar.rx_text
//            .asDriver()
//            .throttle(0.3)
//            .distinctUntilChanged()
//            .drive(self.presenter.updateView)
//            .addDisposableTo(disposeBag)
        self.presenter.sessions.drive(self.tableView.rx_itemsWithDataSource(self.source)).addDisposableTo(self.disposeBag)
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)


//        // Assign ourselves as delegate ONLY in viewWillAppear of a view controller.
//        CastDeviceController *controller = [CastDeviceController sharedInstance];
//        controller.delegate = self;
//
//        UIBarButtonItem *item = [controller queueItemForController:self];
//        self.navigationItem.rightBarButtonItems = @[item];

    }

    // MARK - Private

    func configureTableView() {
        self.clearsSelectionOnViewWillAppear = true
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 100
        self.tableView.delegate = nil
        self.tableView.dataSource = nil
        self.tableView.tableHeaderView = self.searchController.searchBar

        self.tableView.rx_modelSelected(SessionViewModel.self)
            .bindTo(self.presenter.itemSelected)
            .addDisposableTo(self.disposeBag)
    }

}

extension SessionsSearchViewController: SessionsSearchView {

//    var showSessions: AnyObserver<[SessionViewModels]> {
//        return AnyObserver {[unowned self] event in
//            guard case .Next(let sessions) = event else {
//                return
//            }
//            Observable.just(sessions).bindTo(self.tableView.rx_itemsWithDataSource(self.source)).addDisposableTo(self.disposeBag)
//        }
//    }

    var titleText: AnyObserver<String> {
        return self.rx_title
    }
    
    var searchQuery: Observable<String> {
        return self.searchBar.rx_text
            .asObservable()
            .distinctUntilChanged()
    }

}
