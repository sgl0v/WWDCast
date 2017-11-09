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
    private let viewModel: FavoriteSessionsViewModelProtocol

    init(viewModel: FavoriteSessionsViewModelProtocol) {
        self.viewModel = viewModel
        super.init()
        self.rx.viewDidLoad.bind(onNext: self.configureUI).addDisposableTo(self.disposeBag)
        self.rx.viewDidLoad.flatMap(Observable.just(viewModel)).bind(onNext: self.bind).addDisposableTo(self.disposeBag)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func commitPreview(for item: SessionItemViewModel) {
        self.viewModel.didSelect(item: item)
    }

    // MARK: Private

    private func bind(to viewModel: FavoriteSessionsViewModelProtocol) {
        // ViewModel's input
        self.tableView.rx.modelSelected(SessionItemViewModel.self)
            .bind(onNext: viewModel.didSelect)
            .addDisposableTo(self.disposeBag)

        // ViewModel's output

        viewModel.favoriteSessions.drive(self.tableView.rx.items(dataSource: self.source)).addDisposableTo(self.disposeBag)
        viewModel.favoriteSessions.map({ $0.isEmpty }).drive(self.tableView.rx.isHidden).addDisposableTo(self.disposeBag)
        viewModel.favoriteSessions.map({ !$0.isEmpty }).drive(self.emptyDataSetView.rx.isHidden).addDisposableTo(self.disposeBag)
        viewModel.emptyFavorites.drive(onNext: self.emptyDataSetView.bind).addDisposableTo(self.disposeBag)
    }

    private func configureUI() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.castBarButtonItem()
        self.title = NSLocalizedString("Favorites", comment: "Favorte sessions view title")

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
