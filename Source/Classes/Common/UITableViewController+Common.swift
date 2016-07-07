//
//  UITableViewController+Utils.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 05/07/16.
//  Copyright © 2016 Maksym Shcheglov. All rights reserved.
//

import UIKit

public protocol BindableView {
    associatedtype ViewModel
    func bindViewModel(viewModel: ViewModel)
}

public class TableViewController<T, Cell: UITableViewCell where Cell: protocol<BindableView, NibProvidable, ReusableView>, Cell.ViewModel == T>: UITableViewController,  NibProvidable {

    public var data = [T]() {
        didSet {
            self.tableView.reloadData()
            self.tableView.scrollRectToVisible(CGRectZero, animated: true)
        }
    }

    public init() {
        super.init(nibName: self.dynamicType.nibName, bundle: NSBundle.mainBundle())
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.registerNib(cellClass: Cell.self)
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 60
    }

    // MARK: - Table view data source
    override public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }

    override public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withClass: Cell.self, forIndexPath: indexPath)
        cell.bindViewModel(data[indexPath.row])
        return cell
    }
}
