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
        self.definesPresentationContext = true
        
        self.configureTableView()
        self.setupBindings()
    }
    
    func setupBindings() {
        // dismiss keyboard on scroll
        self.tableView.rx_contentOffset.subscribe({[unowned self] _ in
            if self.searchBar.isFirstResponder() {
                _ = self.searchBar.resignFirstResponder()
            }
        }).addDisposableTo(disposeBag)
        self.tableView.rx_modelSelected(SessionViewModel.self)
            .bindTo(self.presenter.itemSelected)
            .addDisposableTo(self.disposeBag)
        
        self.presenter.sessions.drive(self.tableView.rx_itemsWithDataSource(self.source)).addDisposableTo(self.disposeBag)
        self.presenter.title.drive(self.rx_title).addDisposableTo(self.disposeBag)
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }

    // MARK - Private

    func configureTableView() {
        self.clearsSelectionOnViewWillAppear = true
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 100
        self.tableView.delegate = nil
        self.tableView.dataSource = nil
        self.tableView.tableHeaderView = self.searchController.searchBar
    }

}

extension SessionsSearchViewController: SessionsSearchView {

    var titleText: AnyObserver<String> {
        return self.rx_title
    }
    
    var searchQuery: Driver<String> {
        return self.searchBar.rx_text
            .asDriver()
            .throttle(0.3)
            .distinctUntilChanged()
    }

}
