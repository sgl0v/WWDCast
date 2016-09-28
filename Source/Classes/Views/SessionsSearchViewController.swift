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

class SessionsSearchViewController: UIViewController {
    
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!
    private let viewModel: SessionsSearchViewModel
    private let disposeBag = DisposeBag()
    
    init(viewModel: SessionsSearchViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
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
//        searchController.hidesNavigationBarDuringPresentation = false
        return searchController
    }()
    
    private var searchBar: UISearchBar {
        return self.searchController.searchBar
    }
    
    private lazy var source: RxTableViewSectionedReloadDataSource<SessionSectionViewModel> = {
        let dataSource = RxTableViewSectionedReloadDataSource<SessionSectionViewModel>()
        dataSource.configureCell = { (dataSource, tableView, indexPath, element) in
            let cell = tableView.dequeueReusableCell(withClass: SessionTableViewCell.self, forIndexPath: indexPath)
            cell.bindViewModel(element)
            return cell
        }
        dataSource.titleForHeaderInSection = { (dataSource, section) in
            return dataSource.sectionAtIndex(section).description
        }
        return dataSource
    }()
    
    private func bindViewModel() {
        // ViewModel's input
        self.navigationItem.leftBarButtonItem!.rx_tap.bindNext(self.viewModel.filterObserver).addDisposableTo(self.disposeBag)
        self.searchQuery.driveNext(self.viewModel.searchStringObserver).addDisposableTo(self.disposeBag)
        self.tableView.rx_modelSelected(SessionItemViewModel.self)
            .bindNext(self.viewModel.itemSelectionObserver)
            .addDisposableTo(self.disposeBag)
        self.tableView.rx_itemSelected.subscribeNext({ indexPath in
            self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }).addDisposableTo(self.disposeBag)
        
        // ViewModel's output
        
        self.viewModel.sessionSections.drive(self.tableView.rx_itemsWithDataSource(self.source)).addDisposableTo(self.disposeBag)
        self.viewModel.title.drive(self.rx_title).addDisposableTo(self.disposeBag)
        self.viewModel.isLoading.drive(self.tableView.rx_hidden).addDisposableTo(self.disposeBag)
        self.viewModel.isLoading.drive(self.loadingIndicator.rx_animating).addDisposableTo(self.disposeBag)
    }

    private func configureUI() {
        self.edgesForExtendedLayout = .None
        self.definesPresentationContext = true
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.castBarButtonItem()
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Filter", comment: "Filter"), style: .Plain, target: nil, action: nil)

//        self.clearsSelectionOnViewWillAppear = true
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 100
        self.tableView.delegate = nil
        self.tableView.dataSource = nil
        self.tableView.tableHeaderView = self.searchController.searchBar
        self.tableView.layoutMargins = UIEdgeInsetsZero
        self.tableView.tableFooterView = UIView()
        self.tableView.registerNib(cellClass: SessionTableViewCell.self)
        
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
