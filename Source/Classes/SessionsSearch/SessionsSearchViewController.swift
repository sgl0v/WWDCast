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
    
    var viewModel: SessionsSearchPresenter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureUI()
        self.setupBindings()
        self.viewModel.active = true
    }
    
//    override func viewWillAppear(animated: Bool) {
//        super.viewWillAppear(animated)
//        self.viewModel.active = true
//    }
//    
//    override func viewWillDisappear(animated: Bool) {
//        super.viewWillDisappear(animated)
//        self.viewModel.active = false
//    }
    
    // MARK - Private
    
    private lazy var searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.dimsBackgroundDuringPresentation = false
        return searchController
    }()
    
    private var searchBar: UISearchBar {
        return self.searchController.searchBar
    }
    
    private func setupBindings() {
        // dismiss keyboard on scroll
        self.tableView.rx_contentOffset.subscribe({[unowned self] _ in
            if self.searchBar.isFirstResponder() {
                _ = self.searchBar.resignFirstResponder()
            }
            }).addDisposableTo(self.disposeBag)
        // ViewModel's input
        self.navigationItem.leftBarButtonItem!.rx_tap.bindTo(self.viewModel.filterObserver).addDisposableTo(self.disposeBag)
        self.searchQuery.drive(self.viewModel.searchStringObserver).addDisposableTo(self.disposeBag)
        
        // ViewModel's output
        self.tableView.rx_modelSelected(SessionViewModel.self)
            .bindTo(self.viewModel.itemSelected)
            .addDisposableTo(self.disposeBag)
        self.viewModel.sessions.asDriver().drive(self.tableView.rx_itemsWithDataSource(self.source)).addDisposableTo(self.disposeBag)
        self.viewModel.title.drive(self.rx_title).addDisposableTo(self.disposeBag)
    }

    private func configureUI() {        
        self.definesPresentationContext = true
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.castBarButtonItem()
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Filter", comment: "Filter"), style: .Plain, target: nil, action: nil)

        self.clearsSelectionOnViewWillAppear = true
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 100
        self.tableView.delegate = nil
        self.tableView.dataSource = nil
        self.tableView.tableHeaderView = self.searchController.searchBar
        self.tableView.layoutMargins = UIEdgeInsetsZero
        self.tableView.tableFooterView = UIView()
    }

    private var searchQuery: Driver<String> {
        return self.searchBar.rx_text
            .asDriver()
            .throttle(0.1)
            .distinctUntilChanged()
    }

}
