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
    private let viewModel: FavoriteSessionsViewModelType

    init(viewModel: FavoriteSessionsViewModelType) {
        self.viewModel = viewModel
        super.init()
        self.rx.viewDidLoad.bind(onNext: self.configureUI).addDisposableTo(self.disposeBag)
        self.rx.viewDidLoad.map(viewModel).bind(onNext: self.bind).addDisposableTo(self.disposeBag)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Private

    private func bind(to viewModel: FavoriteSessionsViewModelType) {
        // ViewModel's input
        let viewWillAppear = self.rx.viewWillAppear.mapToVoid().asDriverOnErrorJustComplete()
        let modelSelected = self.tableView.rx.modelSelected(SessionItemViewModel.self).asDriverOnErrorJustComplete()
        let commitPreview = self.commitPreview.asDriverOnErrorJustComplete()
        let selection = Driver.merge(modelSelected, commitPreview)

        let input = FavoriteSessionsViewModelInput(loading: viewWillAppear, selection: selection)
        let output = viewModel.transform(input: input)

        // ViewModel's output
        output.favorites.drive(self.tableView.rx.items(dataSource: self.source)).addDisposableTo(self.disposeBag)
        output.favorites.map({ $0.isEmpty }).drive(self.tableView.rx.isHidden).addDisposableTo(self.disposeBag)
        output.favorites.map({ !$0.isEmpty }).drive(self.emptyDataSetView.rx.isHidden).addDisposableTo(self.disposeBag)
        output.selectedItem.drive().addDisposableTo(disposeBag)
        output.empty.drive(onNext: self.emptyDataSetView.bind).addDisposableTo(self.disposeBag)
        output.error.drive(self.errorBinding).addDisposableTo(self.disposeBag)
    }

    private func configureUI() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.castBarButtonItem()
        self.title = NSLocalizedString("Favorites", comment: "Favorte sessions view title")

        self.setClearsSelectionOnViewWillAppear()
        self.registerForPreviewing()
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 100
        self.tableView.tableFooterView = UIView()

        self.view.addSubview(self.emptyDataSetView, constraints: [
            equal(\.leadingAnchor),
            equal(\.trailingAnchor),
            equal(\.topAnchor),
            equal(\.bottomAnchor)
        ])
    }

    private var errorBinding: UIBindingObserver<FavoriteSessionsViewController, Error> {
        return UIBindingObserver(UIElement: self, binding: { (vc, error) in
            vc.showAlert(for: error)
        })
    }

}
