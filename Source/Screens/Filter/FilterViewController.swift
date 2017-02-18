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
    private let viewModel: FilterViewModel

    init(viewModel: FilterViewModel) {
        self.viewModel = viewModel
        super.init()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureUI()
        self.setupBindings()
    }

    // MARK - Private

    private func setupBindings() {
        // ViewModel's input
        self.cancelButton.rx.tap.subscribe(onNext: self.viewModel.didCancel).addDisposableTo(self.disposeBag)
        self.doneButton.rx.tap.subscribe(onNext: self.viewModel.didApplyFilter).addDisposableTo(self.disposeBag)
        self.tableView.rx.itemSelected.subscribe(onNext: {[unowned self] indexPath in
            self.tableView.deselectRow(at: indexPath, animated: true)
        }).addDisposableTo(self.disposeBag)

        // ViewModel's output
        self.viewModel.filterSections.drive(self.tableView.rx.items(dataSource: self.source)).addDisposableTo(self.disposeBag)
        self.viewModel.title.drive(self.rx.title).addDisposableTo(self.disposeBag)
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
