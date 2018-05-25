//
//  ViewController.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 04/07/16.
//  Copyright © 2016 Maksym Shcheglov. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class SessionsSearchViewController: TableViewController<SessionSectionViewModel, SessionTableViewCell> {

    weak var previewProvider: TableViewControllerPreviewProvider?
    private var previewController: SessionDetailsPreview?
    private var loadingIndicator: UIActivityIndicatorView!
    private var filterButton: UIBarButtonItem!
    private var emptyDataSetView: EmptyDataSetView!
    private let viewModel: SessionsSearchViewModelType
    private let sessions = Variable([SessionSectionViewModel]())

    init(viewModel: SessionsSearchViewModelType) {
        self.viewModel = viewModel
        super.init()
        self.rx.viewDidLoad.bind(onNext: self.configureUI).disposed(by: self.disposeBag)
        self.rx.viewDidLoad.map(viewModel).bind(onNext: self.bind).disposed(by: self.disposeBag)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Private

    private lazy var searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.tintColor = UIColor.black
        return searchController
    }()

    private var searchBar: UISearchBar {
        return self.searchController.searchBar
    }

    private func bind(to viewModel: SessionsSearchViewModelType) {
        // ViewModel's input
        let viewWillAppear = self.rx.viewDidAppear.mapToVoid().asDriverOnErrorJustComplete()
        let viewDidDisappear = self.rx.viewDidDisappear.mapToVoid().asDriverOnErrorJustComplete()
        let modelSelected = self.tableView.rx.modelSelected(SessionItemViewModel.self).asDriverOnErrorJustComplete()
        let commitPreview = self.previewController?.commitPreview.map({[unowned self] indexPath in
            return self.source[indexPath]
        }).asDriverOnErrorJustComplete() ?? Driver.empty()
        let selection = Driver.merge(modelSelected, commitPreview)
        let filter = self.filterButton.rx.tap.asDriverOnErrorJustComplete()
        let search = self.searchQuery

        let input = SessionsSearchViewModelInput(appear: viewWillAppear,
                                                 disappear: viewDidDisappear,
                                                 selection: selection,
                                                 filter: filter,
                                                 search: search)
        let output = viewModel.transform(input: input)

        // ViewModel's output
        output.sessions.drive(self.tableView.rx.items(dataSource: self.source)).disposed(by: self.disposeBag)
        output.loading.drive(self.tableView.rx.isHidden).disposed(by: self.disposeBag)
        output.loading.drive(self.loadingIndicator.rx.isAnimating).disposed(by: self.disposeBag)
        output.empty.not().drive(self.emptyDataSetView.rx.isHidden).disposed(by: self.disposeBag)
        output.error.drive(self.errorBinding).disposed(by: self.disposeBag)
    }

    private func configureUI() {
        self.definesPresentationContext = true
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.castBarButtonItem()
        self.filterButton = UIBarButtonItem(title: NSLocalizedString("Filter", comment: "Filter"), style: .plain, target: nil, action: nil)
        self.navigationItem.leftBarButtonItem = self.filterButton
        self.title = NSLocalizedString("WWDCast", comment: "Session search view title")

        self.setClearsSelectionOnViewWillAppear()
        self.registerForPreviewing()

        self.view.backgroundColor = UIColor.white

        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 100
        if #available(iOS 11.0, *) {
            self.navigationItem.searchController = self.searchController
            self.searchController.isActive = true
        } else {
            self.tableView.tableHeaderView = self.searchBar
            // dismiss keyboard on scroll
            self.tableView.rx.contentOffset.asDriver().filter({[unowned self] _ -> Bool in
                return !self.searchController.isBeingPresented && self.searchBar.isFirstResponder
            }).drive(onNext: {[unowned self] _ in
                self.searchBar.resignFirstResponder()
            }).disposed(by: self.disposeBag)
        }

        self.tableView.tableFooterView = UIView()

        self.loadingIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        self.view.addSubview(self.loadingIndicator, constraints: [
            equal(\.centerXAnchor),
            equal(\.centerYAnchor)
        ])
        let emptyTitle = NSLocalizedString("No Results", comment: "No Results")
        let emptyDescription = NSLocalizedString("Please try searching again",
                                                 comment: "Please try searching again")
        let emptySearchImage = UIImage(named: "search") ?? UIImage()
        self.emptyDataSetView = EmptyDataSetView.view(emptyTitle, description: emptyDescription, image: emptySearchImage)
        self.view.addSubview(self.emptyDataSetView, constraints: [
            equal(\.leadingAnchor),
            equal(\.trailingAnchor),
            equal(\.topAnchor),
            equal(\.bottomAnchor)
        ])
    }

    private var errorBinding: Binder<Error> {
        return Binder(self, binding: { (vc, error) in
            vc.showAlert(for: error)
        })
    }

    private var searchQuery: Driver<String> {
        let cancel: Observable<String> = self.searchBar.rx.delegate.methodInvoked(#selector(UISearchBarDelegate.searchBarCancelButtonClicked(_:))).map({ _ in return "" })

        let searchBarTextObservable = self.searchBar.rx.text.rejectNil().unwrap()
        return Observable.of(searchBarTextObservable, cancel)
            .merge()
            .throttle(0.3, scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .asDriverOnErrorJustComplete()
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

}
