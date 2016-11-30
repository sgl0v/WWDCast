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

class TableViewController<SectionViewModel: SectionModelType & CustomStringConvertible, Cell: UITableViewCell>: UIViewController, UIViewControllerPreviewingDelegate where Cell: BindableView & NibProvidable & ReusableView, Cell.ViewModel == SectionViewModel.Item {

    var tableView: UITableView!
    let disposeBag = DisposeBag()

    lazy var source: RxTableViewSectionedReloadDataSource<SectionViewModel> = {
        let dataSource = RxTableViewSectionedReloadDataSource<SectionViewModel>()
        dataSource.configureCell = { (dataSource, tableView, indexPath, element) in
            let cell = tableView.dequeueReusableCell(withClass: Cell.self, forIndexPath: indexPath)!
            cell.bind(viewModel: element)
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
        self.tableView.registerNib(cellClass: Cell.self)
        
        // Get rid of back button's title
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    func setClearsSelectionOnViewWillAppear() {
        self.tableView.rx.itemSelected.asDriver().drive(onNext: {[unowned self] indexPath in
            self.tableView.deselectRow(at: indexPath, animated: true)
        }).addDisposableTo(self.disposeBag)
    }
    
    func registerForPreviewing() {
        // Check for force touch feature, and add force touch/previewing capability.
        if self.traitCollection.forceTouchCapability != .available {
            return
        }
        // Register for `UIViewControllerPreviewingDelegate` to enable "Peek" and "Pop".
        self.registerForPreviewing(with: self, sourceView: self.tableView)
    }
    
    // MARK: UIViewControllerPreviewingDelegate
    
    /// Create a previewing view controller to be shown at "Peek".
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        // Obtain the index path and the cell that was pressed.
        guard let indexPath = self.tableView.indexPathForRow(at: location),
            let cell = self.tableView.cellForRow(at: indexPath),
            let viewModel = try? self.source.model(at: indexPath) else {
                return nil
        }
        // Set the source rect to the cell frame, so surrounding elements are blurred.
        previewingContext.sourceRect = cell.frame
        
        let item = viewModel as! SectionViewModel.Item
        // Create a detail view controller and set its properties.
        return self.previewingContext?.previewControllerForItem(item)
    }
    
    /// Present the view controller for the "Pop" action.
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        self.previewingContext?.commitPreview(viewControllerToCommit)
    }
    
    var previewingContext: TableViewControllerPreviewingContext<SectionViewModel.Item>?
}
