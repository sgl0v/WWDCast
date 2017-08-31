//
//  FilterViewController.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 13/08/2016.
//  Copyright © 2016 Maksym Shcheglov. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class FilterViewController: TableViewController<FilterSectionViewModel, FilterTableViewCell> {
    private var cancelButton: UIBarButtonItem!
    private var doneButton: UIBarButtonItem!

    init(viewModel: FilterViewModel) {
        super.init()
        self.rx.viewDidLoad.bind(onNext: self.configureUI).addDisposableTo(self.disposeBag)
        self.rx.viewDidLoad.flatMap(Observable.just(viewModel)).bind(onNext: self.bind).addDisposableTo(self.disposeBag)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK - Private

    private func bind(to viewModel: FilterViewModel) {
        // ViewModel's input
        self.cancelButton.rx.tap.subscribe(onNext: viewModel.didCancel).addDisposableTo(self.disposeBag)
        self.doneButton.rx.tap.subscribe(onNext: viewModel.didApplyFilter).addDisposableTo(self.disposeBag)
        self.tableView.rx.itemSelected.subscribe(onNext: {[unowned self] indexPath in
            self.tableView.deselectRow(at: indexPath, animated: true)
        }).addDisposableTo(self.disposeBag)

        // ViewModel's output
        viewModel.filterSections.drive(self.tableView.rx.items(dataSource: self.source)).addDisposableTo(self.disposeBag)
        viewModel.title.drive(self.rx.title).addDisposableTo(self.disposeBag)
    }

    private func configureUI() {
        self.cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: nil, action: nil)
        self.doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: nil)
        self.navigationItem.leftBarButtonItem = self.cancelButton
        self.navigationItem.rightBarButtonItem = self.doneButton

        self.setClearsSelectionOnViewWillAppear()
        self.tableView.rowHeight = UITableViewAutomaticDimension
    }

}
