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

extension UITableViewCell {
    public var rx_checkmarkObserver: AnyObserver<Bool> {
        return UIBindingObserver(UIElement: self, binding: { cell, selected in
            cell.accessoryType = selected ? .Checkmark : .None
        }).asObserver()
    }
}

class FilterTableViewCell: RxTableViewCell, ReusableView, BindableView, NibProvidable {
    
    let disposeBag = DisposeBag()
    
    // MARK: SessionTableViewCell
    typealias ViewModel = FilterDrawable
    
    func bindViewModel(viewModel: ViewModel) {
        self.textLabel?.text = viewModel.title
        viewModel.selected.asObservable()
            .takeUntil(self.onPrepareForReuse)
            .bindTo(self.rx_checkmarkObserver)
            .addDisposableTo(self.disposeBag)
        self.layoutMargins = UIEdgeInsetsZero
        self.separatorInset = UIEdgeInsetsZero
    }
    
}


class FilterViewController: TableViewController<FilterSectionDrawable, FilterTableViewCell> {
    var viewModel: FilterViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureUI()
        self.setupBindings()
    }
    
    // MARK - Private
    
    private func setupBindings() {
        // dismiss keyboard on scroll
        self.navigationItem.leftBarButtonItem!.rx_tap.subscribeNext({
            self.dismissViewControllerAnimated(true, completion: nil)
        }).addDisposableTo(self.disposeBag)
        self.navigationItem.rightBarButtonItem!.rx_tap.subscribeNext({
            self.dismissViewControllerAnimated(true, completion: nil)
        }).addDisposableTo(self.disposeBag)
        self.tableView.rx_itemSelected.subscribeNext({ indexPath in
            self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }).addDisposableTo(self.disposeBag)

        self.viewModel.filterItems.drive(self.tableView.rx_itemsWithDataSource(self.source)).addDisposableTo(self.disposeBag)
//        self.viewModel.filterTrigger = self.tableView.rx_itemSelected.asDriver()
        self.tableView.rx_itemSelected.asDriver()
            .drive(self.viewModel.itemSelected)
            .addDisposableTo(self.disposeBag)
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
