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

class FilterViewController: UIViewController {
    private var cancelButton: UIBarButtonItem!
    private var doneButton: UIBarButtonItem!
    private var tableView: UITableView!
    private let disposeBag = DisposeBag()
    typealias SectionViewModel = FilterSectionViewModel
    typealias Cell = FilterTableViewCell

    init(viewModel: FilterViewModel) {
        super.init(nibName: nil, bundle: nil)
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
        viewModel.filterSections.drive(self.tableView.rx.items(dataSource: self.dataSource)).addDisposableTo(self.disposeBag)
        viewModel.title.drive(self.rx.title).addDisposableTo(self.disposeBag)
    }

    lazy var dataSource: RxTableViewSectionedReloadDataSource<SectionViewModel> = {
        let dataSource = RxTableViewSectionedReloadDataSource<SectionViewModel>()
        dataSource.configureCell = { (dataSource, tableView, indexPath, element) in
            let cell = tableView.dequeueReusableCell(withClass: Cell.self, forIndexPath: indexPath)
            cell.bind(to: element)
            return cell
        }
        dataSource.titleForHeaderInSection = { (dataSource: TableViewSectionedDataSource<SectionViewModel>, sectionIndex: Int) -> String? in
            return dataSource[sectionIndex].description
        }
        return dataSource
    }()

    private func configureUI() {
        self.tableView = UITableView(frame: self.view.bounds, style: .plain)
        self.view.addSubview(self.tableView)
        self.tableView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        self.tableView.registerNib(cellClass: Cell.self)
        self.tableView.rx.itemSelected.asDriver().drive(onNext: {[unowned self] indexPath in
            self.tableView.deselectRow(at: indexPath, animated: true)
        }).addDisposableTo(self.disposeBag)
        self.tableView.rowHeight = UITableViewAutomaticDimension

        self.cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: nil, action: nil)
        self.doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: nil)
        self.navigationItem.leftBarButtonItem = self.cancelButton
        self.navigationItem.rightBarButtonItem = self.doneButton
    }

}
