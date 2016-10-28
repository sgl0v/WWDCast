//
//  FavoriteSessionsViewController.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 21/10/2016.
//  Copyright © 2016 Maksym Shcheglov. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class FavoriteSessionsViewController: TableViewController<SessionSectionViewModel, SessionTableViewCell> {
    private let viewModel: FavoriteSessionsViewModel
    private let rx_viewWillAppear = PublishSubject<Void>()
    
    init(viewModel: FavoriteSessionsViewModel) {
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
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        rx_viewWillAppear.on(.Next())
    }

    // MARK - Private
    
    private func bindViewModel() {
        // ViewModel's input
        self.tableView.rx_modelSelected(SessionItemViewModel.self)
            .bindNext(self.viewModel.itemSelectionObserver)
            .addDisposableTo(self.disposeBag)
        
        // ViewModel's output
        
        self.viewModel.favoriteSessions(self.rx_viewWillAppear).drive(self.tableView.rx_itemsWithDataSource(self.source)).addDisposableTo(self.disposeBag)
        self.viewModel.title.drive(self.rx_title).addDisposableTo(self.disposeBag)
    }
    
    private func configureUI() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.castBarButtonItem()
        
        self.clearsSelectionOnViewWillAppear = true
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 100
        self.tableView.delegate = nil
        self.tableView.dataSource = nil
        self.tableView.layoutMargins = UIEdgeInsetsZero
        self.tableView.tableFooterView = UIView()
        self.tableView.registerNib(cellClass: SessionTableViewCell.self)
    }
    
}
