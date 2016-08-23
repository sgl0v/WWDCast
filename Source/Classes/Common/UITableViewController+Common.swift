//
//  UITableViewController+Utils.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 05/07/16.
//  Copyright © 2016 Maksym Shcheglov. All rights reserved.
//

import UIKit
import RxSwift
import RxDataSources

public protocol BindableView {
    associatedtype ViewModel
    func bindViewModel(viewModel: ViewModel)
}

public class TableViewController<SectionViewModel: protocol<SectionModelType, CustomStringConvertible>, Cell: UITableViewCell where Cell: protocol<BindableView, NibProvidable, ReusableView>, Cell.ViewModel == SectionViewModel.Item>: UITableViewController {

    let disposeBag = DisposeBag()

    lazy var source: RxTableViewSectionedReloadDataSource<SectionViewModel> = {
        let dataSource = RxTableViewSectionedReloadDataSource<SectionViewModel>()
        dataSource.configureCell = { (dataSource, tableView, indexPath, element) in
            let cell = tableView.dequeueReusableCell(withClass: Cell.self, forIndexPath: indexPath)
            cell.bindViewModel(element)
            return cell
        }
        dataSource.titleForHeaderInSection = { (dataSource, section) in
            return dataSource.sectionAtIndex(section).description
        }
        return dataSource
    }()

    public init() {
        super.init(nibName: nil, bundle: nil)
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.registerNib(cellClass: Cell.self)
    }

}
