//
//  SessionDetailsViewController.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 06/07/16.
//  Copyright © 2016 Maksym Shcheglov. All rights reserved.
//

import UIKit
import RxSwift

class SessionDetailsViewController: UIViewController, NibProvidable {

    @IBOutlet private weak var image: UIImageView!
    @IBOutlet private weak var header: UILabel!
    @IBOutlet private weak var summary: UILabel!
    @IBOutlet private weak var subtitle: UILabel!
    @IBOutlet private weak var playButton: UIButton!
    @IBOutlet private weak var favoriteButton: UIButton!

    private let viewModel: SessionDetailsViewModel
    private let disposeBag = DisposeBag()

    init(viewModel: SessionDetailsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureUI()
        self.bindViewModel()
    }

    // MARK: Private

    private func configureUI() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.castBarButtonItem()
        self.edgesForExtendedLayout = UIRectEdge()
    }

    private func bindViewModel() {
        // ViewModel's input
        self.playButton.rx.tap.subscribe(onNext: self.viewModel.didTapPlaySession).addDisposableTo(self.disposeBag)
        self.favoriteButton.rx.tap.subscribe(onNext: self.viewModel.didToggleFavorite).addDisposableTo(self.disposeBag)

        // ViewModel's output
        self.viewModel.session.drive(onNext: self.viewModelObserver).addDisposableTo(self.disposeBag)
        self.viewModel.title.drive(self.rx.title).addDisposableTo(self.disposeBag)
    }

    private func viewModelObserver(_ viewModel: SessionItemViewModel?) {
        guard let viewModel = viewModel else {
            return
        }
        Observable.just(viewModel.thumbnailURL)
            .asObservable()
            .bindTo(self.image.rx.imageURL)
            .addDisposableTo(self.disposeBag)
        self.header.text = viewModel.title
        self.summary.text = viewModel.summary
        self.subtitle.text = viewModel.subtitle
        self.favoriteButton.isSelected = viewModel.favorite
    }

}
