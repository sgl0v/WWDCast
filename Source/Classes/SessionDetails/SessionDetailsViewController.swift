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

    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var header: UILabel!
    @IBOutlet weak var summary: UILabel!
    @IBOutlet weak var focus: UILabel!

    var presenter: SessionDetailsPresenter!
    let disposeBag = DisposeBag()

    init() {
        super.init(nibName: self.dynamicType.nibName, bundle: NSBundle.mainBundle())
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.presenter.session.drive(self.viewModelObserver)
            .addDisposableTo(self.disposeBag)
    }

    // MARK: Private

    var viewModelObserver: AnyObserver<SessionViewModel?> {
        return AnyObserver<SessionViewModel?> { event in
            guard case .Next(let tmp) = event else {
                return
            }
            guard let viewModel = tmp else {
                return
            }
            Observable.just(viewModel.thumbnailURL)
                .asObservable()
                .bindTo(self.image.rx_imageURL)
                .addDisposableTo(self.disposeBag)
            self.header.text = viewModel.title
            self.summary.text = viewModel.summary
        }
    }

}

extension SessionDetailsViewController: SessionDetailsView {

}
