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
        self.rx.viewDidLoad.map(viewModel).bind(onNext: {[unowned self] viewModel in
            self.configureUI()
            self.bind(to: viewModel)
        }).disposed(by: self.disposeBag)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Private

    private func bind(to viewModel: FilterViewModel) {
        // ViewModel's input
        let viewWillAppear = self.rx.viewWillAppear.mapToVoid().asDriverOnErrorJustComplete()
        let selection = self.tableView.rx.itemSelected.asDriverOnErrorJustComplete()
        let cancel = self.cancelButton.rx.tap.mapToVoid().asDriverOnErrorJustComplete()
        let apply = self.doneButton.rx.tap.mapToVoid().asDriverOnErrorJustComplete()

        let input = FilterViewModelInput(loading: viewWillAppear, selection: selection, cancel: cancel, apply: apply)
        let output = viewModel.transform(input: input)

        // ViewModel's output
        output.filterSections.drive(self.tableView.rx.items(dataSource: self.dataSource)).disposed(by: self.disposeBag)
    }

    lazy var dataSource: RxTableViewSectionedReloadDataSource<SectionViewModel> = {
        let dataSource = RxTableViewSectionedReloadDataSource<SectionViewModel>(configureCell: { (_, tableView, indexPath, element) in
            let cell = tableView.dequeueReusableCell(withClass: Cell.self, forIndexPath: indexPath)
            cell.bind(to: element)
            return cell
        })
        dataSource.titleForHeaderInSection = { (dataSource: TableViewSectionedDataSource<SectionViewModel>, sectionIndex: Int) -> String? in
            return dataSource[sectionIndex].title
        }
        return dataSource
    }()

    private func configureUI() {
        self.title = NSLocalizedString("Filter", comment: "Filter view title")

        self.tableView = UITableView(frame: self.view.bounds, style: .plain)
        self.view.addSubview(self.tableView, constraints: [
            equal(\.leadingAnchor),
            equal(\.trailingAnchor),
            equal(\.topAnchor),
            equal(\.bottomAnchor)
        ])
        self.tableView.registerNib(cellClass: Cell.self)
        self.tableView.rx.itemSelected.asDriver().drive(onNext: {[unowned self] indexPath in
            self.tableView.deselectRow(at: indexPath, animated: true)
        }).disposed(by: self.disposeBag)
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.setClearsSelectionOnViewWillAppear()

        self.cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: nil, action: nil)
        self.doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: nil)
        self.navigationItem.leftBarButtonItem = self.cancelButton
        self.navigationItem.rightBarButtonItem = self.doneButton
    }

    func setClearsSelectionOnViewWillAppear() {
        self.tableView.rx.itemSelected.asDriver().drive(onNext: {[unowned self] indexPath in
            self.tableView.deselectRow(at: indexPath, animated: true)
        }).disposed(by: self.disposeBag)
    }

}
