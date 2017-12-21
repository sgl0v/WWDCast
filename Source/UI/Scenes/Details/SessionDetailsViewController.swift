//
//  SessionDetailsViewController.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 06/07/16.
//  Copyright © 2016 Maksym Shcheglov. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class SessionDetailsViewController: UIViewController, NibProvidable {

    @IBOutlet private weak var image: UIImageView!
    @IBOutlet private weak var header: UILabel!
    @IBOutlet private weak var summary: UILabel!
    @IBOutlet private weak var subtitle: UILabel!
    @IBOutlet private weak var playButton: UIButton!
    @IBOutlet private weak var favoriteButton: UIButton!

    private let disposeBag = DisposeBag()
    private let playbackTrigger = PublishSubject<Int>()

    init(viewModel: SessionDetailsViewModelType) {
        super.init(nibName: nil, bundle: nil)
        self.rx.viewDidLoad.bind(onNext: self.configureUI).addDisposableTo(self.disposeBag)
        self.rx.viewDidLoad.map(viewModel).bind(onNext: self.bind).addDisposableTo(self.disposeBag)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Private

    private func configureUI() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.castBarButtonItem()
        self.header.text = NSLocalizedString("Session Details", comment: "Session details view title")
    }

    private func bind(to viewModel: SessionDetailsViewModelType) {
        // ViewModel's input
        let viewWillAppear = self.rx.viewWillAppear.mapToVoid().asDriverOnErrorJustComplete()
        let toggleFavorite = self.favoriteButton.rx.tap.mapToVoid().asDriverOnErrorJustComplete()
        let showDevices = self.playButton.rx.tap.mapToVoid().asDriverOnErrorJustComplete()
        let startPlayback = self.playbackTrigger.asDriverOnErrorJustComplete()

        let input = SessionDetailsViewModelInput(load: viewWillAppear, toggleFavorite: toggleFavorite, showDevices: showDevices, startPlayback: startPlayback)
        let output = viewModel.transform(input: input)

        // ViewModel's output
        output.session.drive(self.sessionBinding).addDisposableTo(self.disposeBag)
        output.devices.drive(self.devicesBinding).addDisposableTo(self.disposeBag)
        output.playback.drive().addDisposableTo(disposeBag)
        output.error.drive(self.errorBinding).addDisposableTo(self.disposeBag)
    }

    private var sessionBinding: UIBindingObserver<SessionDetailsViewController, SessionItemViewModel> {
        return UIBindingObserver(UIElement: self, binding: { (vc, viewModel) in
            Observable.just(viewModel.thumbnailURL)
                .asObservable()
                .bind(to: vc.image.rx.imageURL)
                .addDisposableTo(vc.disposeBag)
            vc.summary.text = viewModel.summary
            vc.subtitle.text = viewModel.subtitle
            vc.favoriteButton.isSelected = viewModel.favorite
        })
    }

    private var devicesBinding: UIBindingObserver<SessionDetailsViewController, [String]> {
        return UIBindingObserver(UIElement: self, binding: { (vc, devices) in
            let cancelAction = NSLocalizedString("Cancel", comment: "Cancel ActionSheet button title")
            vc.showAlert(with: nil, message: nil, cancelAction: cancelAction, actions: devices).subscribe(onNext: { idx in
                vc.playbackTrigger.onNext(idx)
            }).addDisposableTo(vc.disposeBag)
        })
    }

    private var errorBinding: UIBindingObserver<SessionDetailsViewController, Error> {
        return UIBindingObserver(UIElement: self, binding: { (vc, error) in
            vc.showAlert(for: error)
        })
    }

}
