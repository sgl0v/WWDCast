//
//  FavoriteSessionsViewController.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 21/10/2016.
//  Copyright © 2016 Maksym Shcheglov. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class FavoriteSessionsViewController: TableViewController<SessionSectionViewModel, SessionTableViewCell> {
    weak var previewProvider: TableViewControllerPreviewProvider?
    private var previewController: SessionDetailsPreview?
    private var emptyDataSetView: EmptyDataSetView!
    private let viewModel: FavoriteSessionsViewModelType

    init(viewModel: FavoriteSessionsViewModelType) {
        self.viewModel = viewModel
        super.init()
        self.rx.viewDidLoad.bind(onNext: self.configureUI).disposed(by: self.disposeBag)
        self.rx.viewDidLoad.map(viewModel).bind(onNext: self.bind).disposed(by: self.disposeBag)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Private

    private func bind(to viewModel: FavoriteSessionsViewModelType) {
        // ViewModel's input
        let viewWillAppear = self.rx.viewWillAppear.mapToVoid().asDriverOnErrorJustComplete()
        let viewDidDisappear = self.rx.viewDidDisappear.mapToVoid().asDriverOnErrorJustComplete()
        let modelSelected = self.tableView.rx.modelSelected(SessionItemViewModel.self).asDriverOnErrorJustComplete()
        let commitPreview = self.previewController?.commitPreview.map({[unowned self] indexPath in
            return self.source[indexPath]
        }).asDriverOnErrorJustComplete() ?? Driver.empty()
        let selection = Driver.merge(modelSelected, commitPreview)

        let input = FavoriteSessionsViewModelInput(appear: viewWillAppear, disappear: viewDidDisappear, selection: selection)
        let output = viewModel.transform(input: input)

        // ViewModel's output
        output.favorites.drive(self.tableView.rx.items(dataSource: self.source)).disposed(by: self.disposeBag)
        output.empty.drive(self.tableView.rx.isHidden).disposed(by: self.disposeBag)
        output.empty.not().drive(self.emptyDataSetView.rx.isHidden).disposed(by: self.disposeBag)
        output.error.drive(self.errorBinding).disposed(by: self.disposeBag)
    }

    private func configureUI() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.castBarButtonItem()
        self.title = NSLocalizedString("Favorites", comment: "Favorte sessions view title")

        self.setClearsSelectionOnViewWillAppear()
        self.registerForPreviewing()
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 100
        self.tableView.tableFooterView = UIView()

        let emptyTitle = NSLocalizedString("No Favorites", comment: "The are no sessions added to favorites")
        let emptyDescription = NSLocalizedString("Add your favorite sessions to the bookmarks",
                                                 comment: "Add your favorite sessions to the bookmarks")
        self.emptyDataSetView = EmptyDataSetView.view(emptyTitle, description: emptyDescription)
        self.view.addSubview(self.emptyDataSetView, constraints: [
            equal(\.leadingAnchor),
            equal(\.trailingAnchor),
            equal(\.topAnchor),
            equal(\.bottomAnchor)
        ])
    }

    private func registerForPreviewing() {
        // Check for force touch feature, and add force touch/previewing capability.
        if self.traitCollection.forceTouchCapability != .available {
            return
        }

        let previewController = SessionDetailsPreview(source: {[weak self] indexPath in
            guard let viewModel = self?.source[indexPath] else {
                return nil
            }
            return self?.previewProvider?.previewController(forItem: viewModel)
        })
        self.registerForPreviewing(with: previewController, sourceView: self.tableView)
        self.previewController = previewController
    }

    private var errorBinding: Binder<Error> {
        return Binder(self, binding: { (vc, error) in
            vc.showAlert(for: error)
        })
    }

}
