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

extension RxTableViewCell {
    
    var rx_accessoryCheckmark: ControlProperty<Bool> {
        let getter: UITableViewCell -> Bool = { cell in
            cell.accessoryType == .Checkmark
        }
        let setter: (UITableViewCell, Bool) -> Void = { cell, selected in
            cell.accessoryType = selected ? .Checkmark : .None
        }
        let values: Observable<Bool> = Observable.deferred { [weak self] in
            guard let existingSelf = self else {
                return Observable.empty()
            }
            
            return existingSelf.onSelected.map({ _ in true }).startWith(getter(existingSelf))
        }
        return ControlProperty(values: values, valueSink: UIBindingObserver(UIElement: self) { control, value in
            setter(control, value)
        })
    }
}

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
        }).addDisposableTo(disposeBag)
        
        self.textLabel?.text = viewModel.title
        
        if case .Switch = viewModel.style {
            let switchButton = UISwitch()
            switchButton.rx_value <-> viewModel.selected
            self.accessoryView = switchButton
        } else {
            self.rx_accessoryCheckmark <-> viewModel.selected
        }
        
        self.disposeBag = disposeBag
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
//        self.tableView.rx_itemSelected.asDriver()
//            .drive(self.viewModel.itemSelected)
//            .addDisposableTo(self.disposeBag)
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
