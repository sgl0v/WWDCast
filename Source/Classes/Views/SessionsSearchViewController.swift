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

class SessionsSearchViewController: TableViewController<SessionSectionViewModel, SessionTableViewCell>
{
    
    private var loadingIndicator: UIActivityIndicatorView!
    private let viewModel: SessionsSearchViewModel

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
    
    private lazy var searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.tintColor = UIColor.black
        return searchController
    }()
    
    private var searchBar: UISearchBar {
        return self.searchController.searchBar
    }
    
    private func bindViewModel() {
        // ViewModel's input
        self.navigationItem.leftBarButtonItem!.rx.tap.bindNext(self.viewModel.didTapFilter).addDisposableTo(self.disposeBag)
        self.searchQuery.drive(onNext: self.viewModel.didStartSearch).addDisposableTo(self.disposeBag)
        self.tableView.rx.modelSelected(SessionItemViewModel.self)
            .bindNext(self.viewModel.didSelect)
            .addDisposableTo(self.disposeBag)
        
        // ViewModel's output
        
        self.viewModel.sessionSections.drive(self.tableView.rx.items(dataSource: self.source)).addDisposableTo(self.disposeBag)
        self.viewModel.title.drive(self.rx.title).addDisposableTo(self.disposeBag)
        self.viewModel.isLoading.drive(self.tableView.rx.isHidden).addDisposableTo(self.disposeBag)
        self.viewModel.isLoading.drive(self.loadingIndicator.rx.isAnimating).addDisposableTo(self.disposeBag)
    }

    private func configureUI() {
        self.definesPresentationContext = true
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.castBarButtonItem()
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Filter", comment: "Filter"), style: .plain, target: nil, action: nil)

        self.setClearsSelectionOnViewWillAppear()
        
        self.view.backgroundColor = UIColor.white

        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 100
        self.tableView.tableHeaderView = self.searchBar
        self.tableView.tableFooterView = UIView()
        
        // dismiss keyboard on scroll
        self.tableView.rx.contentOffset.asDriver().filter({[unowned self] _ -> Bool in
            return !self.searchController.isBeingPresented && self.searchBar.isFirstResponder
        }).drive(onNext: {[unowned self] _ in
            self.searchBar.resignFirstResponder()
        }).addDisposableTo(self.disposeBag)
        
        self.loadingIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        self.view.addSubview(self.loadingIndicator)
        self.loadingIndicator.hidesWhenStopped = true
        self.loadingIndicator.frame.origin.x = self.view.bounds.midX
        self.loadingIndicator.frame.origin.y = self.view.bounds.midY
        self.loadingIndicator.autoresizingMask = [.flexibleLeftMargin, .flexibleTopMargin, .flexibleRightMargin, .flexibleBottomMargin]
    }

    private var searchQuery: Driver<String> {
        let cancel: Observable<String> = self.searchBar.rx.delegate.methodInvoked(#selector(UISearchBarDelegate.searchBarCancelButtonClicked(_:))).map( { _ in return "" })
        
        let searchBarTextObservable = self.searchBar.rx.text.filter({ $0 != nil }).map({ $0! })
        return Observable.of(searchBarTextObservable, cancel)
            .merge()
            .asDriver(onErrorJustReturn: "")
            .throttle(0.1)
            .distinctUntilChanged()
    }

}
