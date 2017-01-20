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
    private let emptyDataSetView = EmptyDataSetView.view()
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

    override func commitPreview(forItem item: SessionItemViewModel) {
        self.viewModel.didSelect(item: item)
    }

    // MARK - Private

    private func bindViewModel() {
        // ViewModel's input
        self.tableView.rx.modelSelected(SessionItemViewModel.self)
            .bindNext(self.viewModel.didSelect)
            .addDisposableTo(self.disposeBag)

        // ViewModel's output

        self.viewModel.favoriteSessions.drive(self.tableView.rx.items(dataSource: self.source)).addDisposableTo(self.disposeBag)
        self.viewModel.favoriteSessions.map({ $0.isEmpty }).drive(self.tableView.rx.isHidden).addDisposableTo(self.disposeBag)
        self.viewModel.favoriteSessions.map({ !$0.isEmpty }).drive(self.emptyDataSetView.rx.isHidden).addDisposableTo(self.disposeBag)
        self.viewModel.title.drive(self.rx.title).addDisposableTo(self.disposeBag)
        self.viewModel.emptyFavorites.drive(onNext: self.emptyDataSetView.bind).addDisposableTo(self.disposeBag)
    }

    private func configureUI() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.castBarButtonItem()

        self.setClearsSelectionOnViewWillAppear()
        self.registerForPreviewing()
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 100
        self.tableView.tableFooterView = UIView()

        self.view.addSubview(self.emptyDataSetView)
        self.emptyDataSetView.frame = self.view.bounds
        self.emptyDataSetView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }

}
