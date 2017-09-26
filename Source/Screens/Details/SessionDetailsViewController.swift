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

    private let disposeBag = DisposeBag()

    init(viewModel: SessionDetailsViewModelProtocol) {
        super.init(nibName: nil, bundle: nil)
        self.rx.viewDidLoad.bind(onNext: self.configureUI).addDisposableTo(self.disposeBag)
        self.rx.viewDidLoad.flatMap(Observable.just(viewModel)).bind(onNext: self.bind).addDisposableTo(self.disposeBag)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Private

    private func configureUI() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.castBarButtonItem()
        self.edgesForExtendedLayout = UIRectEdge()
    }

    private func bind(to viewModel: SessionDetailsViewModelProtocol) {
        // ViewModel's input
        self.playButton.rx.tap.withLatestFrom(viewModel.devices).flatMap(self.selectDeviceForPlayback)
            .subscribe(onNext: viewModel.startPlaybackOnDevice).addDisposableTo(self.disposeBag)
        self.favoriteButton.rx.tap.subscribe(onNext: viewModel.toggleFavorite).addDisposableTo(self.disposeBag)

        // ViewModel's output
        viewModel.session.drive(onNext: self.sessionObserver).addDisposableTo(self.disposeBag)
        viewModel.title.drive(self.rx.title).addDisposableTo(self.disposeBag)
        viewModel.error.drive(onNext: self.showAlert).addDisposableTo(self.disposeBag)
    }

    private func sessionObserver(_ viewModel: SessionItemViewModel?) {
        guard let viewModel = viewModel else {
            return
        }
        Observable.just(viewModel.thumbnailURL)
            .asObservable()
            .bind(to: self.image.rx.imageURL)
            .addDisposableTo(self.disposeBag)
        self.header.text = viewModel.title
        self.summary.text = viewModel.summary
        self.subtitle.text = viewModel.subtitle
        self.favoriteButton.isSelected = viewModel.favorite
    }

    private func selectDeviceForPlayback(_ devices: [String]) -> Observable<Int> {
        if devices.isEmpty {
            self.showAlert(with: nil, message: NSLocalizedString("Google Cast device is not found!", comment: ""))
            return Observable.empty()
        }

        let actions = devices.map({ device in return device.description })
        let cancelAction = NSLocalizedString("Cancel", comment: "Cancel ActionSheet button title")
        let alert = self.showAlert(with: nil, message: nil, cancelAction: cancelAction, actions: actions)
        let deviceObservable = alert.flatMap({ selection -> Observable<Int> in
            switch selection {
            case .action(let idx):
                return Observable.just(idx)
            case .cancel:
                return Observable.empty()
            }
        })
        return deviceObservable
    }

}
