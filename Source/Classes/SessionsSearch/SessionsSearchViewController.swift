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
    
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    private let viewModel: SessionsSearchPresenter
    
    init(viewModel: SessionsSearchPresenter) {
        self.viewModel = viewModel
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureUI()
        self.bindViewModel()
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
//        searchController.hidesNavigationBarDuringPresentation = false
        return searchController
    }()
    
    private var searchBar: UISearchBar {
        return self.searchController.searchBar
    }
    
    private func bindViewModel() {
        // ViewModel's input
        self.navigationItem.leftBarButtonItem!.rx_tap.bindNext(self.viewModel.filterObserver).addDisposableTo(self.disposeBag)
        self.searchQuery.driveNext(self.viewModel.searchStringObserver).addDisposableTo(self.disposeBag)
        self.tableView.rx_modelSelected(SessionViewModel.self)
            .bindNext(self.viewModel.itemSelectionObserver)
            .addDisposableTo(self.disposeBag)
        
        // ViewModel's output
        self.viewModel.sessions.asDriver().drive(self.tableView.rx_itemsWithDataSource(self.source)).addDisposableTo(self.disposeBag)
        self.viewModel.title.drive(self.rx_title).addDisposableTo(self.disposeBag)
//        self.viewModel.isLoading.drive(self.view.rx_hidden).addDisposableTo(self.disposeBag)
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
        
        // dismiss keyboard on scroll
        self.tableView.rx_contentOffset.asDriver()
            .filter({[unowned self] _ -> Bool in
                return !self.searchController.isBeingPresented()
            }).driveNext({[unowned self] _ in
                if self.searchBar.isFirstResponder() {
                    _ = self.searchBar.resignFirstResponder()
                }
            }).addDisposableTo(self.disposeBag)
    }

    private var searchQuery: Driver<String> {
        let cancel = searchController.searchBar.rx_delegate.observe(#selector(UISearchBarDelegate.searchBarCancelButtonClicked(_:))).map( { _ in return "" })
        
        return Observable.of(self.searchBar.rx_text.asObservable(), cancel)
            .merge()
            .asDriver(onErrorJustReturn: "")
            .throttle(0.1)
            .distinctUntilChanged()
    }

}
