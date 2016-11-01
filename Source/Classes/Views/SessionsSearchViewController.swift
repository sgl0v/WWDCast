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

class SessionsSearchViewController: TableViewController<SessionSectionViewModel, SessionTableViewCell> {
    
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    fileprivate let viewModel: SessionsSearchViewModel
    
    init(viewModel: SessionsSearchViewModel) {
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
    }
    
    // MARK - Private
    
    fileprivate lazy var searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.dimsBackgroundDuringPresentation = false
        return searchController
    }()
    
    fileprivate var searchBar: UISearchBar {
        return self.searchController.searchBar
    }
    
    fileprivate func bindViewModel() {
        // ViewModel's input
        self.navigationItem.leftBarButtonItem!.rx.tap.bindNext(self.viewModel.filterObserver).addDisposableTo(self.disposeBag)
        self.searchQuery.drive(onNext: self.viewModel.searchStringObserver).addDisposableTo(self.disposeBag)
        self.tableView.rx.modelSelected(SessionItemViewModel.self)
            .bindNext(self.viewModel.itemSelectionObserver)
            .addDisposableTo(self.disposeBag)
        
        // ViewModel's output
        
        self.viewModel.sessionSections.drive(self.tableView.rx.items(dataSource: self.source)).addDisposableTo(self.disposeBag)
        self.viewModel.title.drive(self.rx.title).addDisposableTo(self.disposeBag)
        self.viewModel.isLoading.drive(self.view.rx.isHidden).addDisposableTo(self.disposeBag)
//        self.viewModel.isLoading.drive(self.loadingIndicator.rx.animating).addDisposableTo(self.disposeBag)
    }

    fileprivate func configureUI() {
        self.definesPresentationContext = true
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.castBarButtonItem()
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Filter", comment: "Filter"), style: .plain, target: nil, action: nil)

        self.clearsSelectionOnViewWillAppear = true
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 100
        self.tableView.delegate = nil
        self.tableView.dataSource = nil
        self.tableView.tableHeaderView = self.searchController.searchBar
        self.tableView.layoutMargins = UIEdgeInsets.zero
        self.tableView.tableFooterView = UIView()
        self.tableView.registerNib(cellClass: SessionTableViewCell.self)
        
        // dismiss keyboard on scroll
        self.tableView.rx.contentOffset.asDriver()
            .filter({[unowned self] _ -> Bool in
                return !self.searchController.isBeingPresented
                }).drive(onNext: {[unowned self] _ in
                if self.searchBar.isFirstResponder {
                    _ = self.searchBar.resignFirstResponder()
                }
            }).addDisposableTo(self.disposeBag)
    }

    fileprivate var searchQuery: Driver<String> {
        let cancel: Observable<String> = searchController.searchBar.rx.delegate.methodInvoked(#selector(UISearchBarDelegate.searchBarCancelButtonClicked(_:))).map( { _ in return "" })
        
        let searchBarTextObservable = self.searchBar.rx.text.filter({ $0 != nil }).map({ $0! })
        return Observable.of(searchBarTextObservable, cancel)
            .merge()
            .asDriver(onErrorJustReturn: "")
            .throttle(0.1)
            .distinctUntilChanged()
    }

}
