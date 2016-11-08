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

class TableViewController<SectionViewModel: SectionModelType & CustomStringConvertible, Cell: UITableViewCell>: UIViewController where Cell: BindableView & NibProvidable & ReusableView, Cell.ViewModel == SectionViewModel.Item {

    var tableView: UITableView!
    let disposeBag = DisposeBag()

    lazy var source: RxTableViewSectionedReloadDataSource<SectionViewModel> = {
        let dataSource = RxTableViewSectionedReloadDataSource<SectionViewModel>()
        dataSource.configureCell = { (dataSource, tableView, indexPath, element) in
            let cell = tableView.dequeueReusableCell(withClass: Cell.self, forIndexPath: indexPath)!
            cell.bindViewModel(element)
            return cell
        }
        dataSource.titleForHeaderInSection = { (dataSource: TableViewSectionedDataSource<SectionViewModel>, sectionIndex: Int) -> String? in
            return dataSource[sectionIndex].description
        }
        return dataSource
    }()

    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView = UITableView(frame: self.view.bounds, style: .plain)
        self.view.addSubview(self.tableView)
        self.tableView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        self.tableView.delegate = nil
        self.tableView.dataSource = nil
        self.tableView.layoutMargins = UIEdgeInsets.zero
        self.tableView.tableFooterView = UIView()
        self.tableView.registerNib(cellClass: Cell.self)
    }

}
