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

struct FilterDrawable: SectionModelType, CustomStringConvertible {
    let items: [String]
    
    init(items: [String]) {
        self.items = items
    }
    
    // MARK: SectionModelType
    
    typealias Item = String
    
    init(original: FilterDrawable, items: [Item]) {
        self.items = items
    }
    
    // MARK: CustomStringConvertible
    var description : String {
        return " "
    }

}

class FilterTableViewCell: RxTableViewCell, ReusableView, BindableView, NibProvidable {
    
    // MARK: SessionTableViewCell
    typealias ViewModel = String
    
    func bindViewModel(viewModel: ViewModel) {
        self.textLabel?.text = viewModel
        self.accessoryType = .None
        self.layoutMargins = UIEdgeInsetsZero
        self.separatorInset = UIEdgeInsetsZero
    }
}


class FilterViewController: TableViewController<FilterDrawable, FilterTableViewCell> {
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

        let models = [FilterDrawable(items: ["All years", "WWDC 2016", "WWDC 2015", "WWDC 2014"]),
                      FilterDrawable(items: ["All Platforms", "iOS", "macOS", "tvOS", "watchOS"]),
                      FilterDrawable(items: ["Featured", "Media", "Developer Tools", "Graphics and Games", "System Frameworks", "App Frameworks", "Design", "Distribution"])]
        Observable.just(models).asDriver(onErrorJustReturn: []).drive(self.tableView.rx_itemsWithDataSource(self.source)).addDisposableTo(self.disposeBag)
        self.tableView.rx_modelSelected(FilterDrawable.self)
            .bindTo(self.viewModel.itemSelected)
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
