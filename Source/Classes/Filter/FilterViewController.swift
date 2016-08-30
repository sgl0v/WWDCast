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

class FilterTableViewCell: RxTableViewCell, ReusableView, BindableView, NibProvidable {
    
    var disposeBag: DisposeBag?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layoutMargins = UIEdgeInsetsZero
        self.separatorInset = UIEdgeInsetsZero
    }
    
    // MARK: SessionTableViewCell
    typealias ViewModel = FilterItemViewModel
    
    func bindViewModel(viewModel: ViewModel) {
        let disposeBag = DisposeBag()
        self.onPrepareForReuse.subscribeNext({[unowned self] in
            self.disposeBag = nil
            self.accessoryView = nil
            self.accessoryType = .None
        }).addDisposableTo(disposeBag)
        
        self.textLabel?.text = viewModel.title
        
        if case .Switch = viewModel.style {
            let switchButton = UISwitch()
            (switchButton.rx_value <-> viewModel.selected).addDisposableTo(disposeBag)
            self.accessoryView = switchButton
        } else {
            (self.rx_accessoryCheckmark <-> viewModel.selected).addDisposableTo(disposeBag)
        }
        
        self.disposeBag = disposeBag
    }
    
}


class FilterViewController: TableViewController<FilterSectionViewModel, FilterTableViewCell> {
    let viewModel: FilterViewModel
    
    init(viewModel: FilterViewModel) {
        self.viewModel = viewModel
        super.init()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureUI()
        self.setupBindings()
    }
    
    // MARK - Private
    
    private func setupBindings() {
        // dismiss keyboard on scroll
        self.navigationItem.leftBarButtonItem!.rx_tap.map({ true }).subscribeNext(self.viewModel.dismissObserver).addDisposableTo(self.disposeBag)
        self.navigationItem.rightBarButtonItem!.rx_tap.map({ false }).subscribeNext(self.viewModel.dismissObserver).addDisposableTo(self.disposeBag)
        self.tableView.rx_itemSelected.subscribeNext({ indexPath in
            self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }).addDisposableTo(self.disposeBag)

        self.viewModel.filterItems.drive(self.tableView.rx_itemsWithDataSource(self.source)).addDisposableTo(self.disposeBag)
    }

    private func configureUI() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.castBarButtonItem()
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Cancel, target: nil, action: nil)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: nil, action: nil)
        
        self.clearsSelectionOnViewWillAppear = true
        self.tableView.rowHeight = 44
        self.tableView.delegate = nil
        self.tableView.dataSource = nil
        self.tableView.layoutMargins = UIEdgeInsetsZero
        self.tableView.tableFooterView = UIView()
    }
    
}
