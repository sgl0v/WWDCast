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
    
    // MARK - Private
    
    private func bindViewModel() {
        // ViewModel's input
        self.tableView.rx.modelSelected(SessionItemViewModel.self)
            .bindNext(self.viewModel.itemSelectionObserver)
            .addDisposableTo(self.disposeBag)
        
        // ViewModel's output
        
        self.viewModel.favoriteSessions.drive(self.tableView.rx.items(dataSource: self.source)).addDisposableTo(self.disposeBag)
        self.viewModel.title.drive(self.rx.title).addDisposableTo(self.disposeBag)
    }
    
    private func configureUI() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.castBarButtonItem()
        
//        self.clearsSelectionOnViewWillAppear = true
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 100
    }
    
}
