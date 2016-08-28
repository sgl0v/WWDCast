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
    @IBOutlet weak var subtitle: UILabel!
    @IBOutlet weak var playButton: UIButton!

    private let viewModel: SessionDetailsViewModel
    private let  disposeBag = DisposeBag()

    init(viewModel: SessionDetailsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.castBarButtonItem()
        self.edgesForExtendedLayout = .None
        
        // ViewModel's input
        self.playButton.rx_tap.subscribeNext(self.viewModel.playSession).addDisposableTo(self.disposeBag)
        
        // ViewModel's output
        self.viewModel.session.drive(self.viewModelObserver).addDisposableTo(self.disposeBag)
        self.viewModel.title.drive(self.rx_title).addDisposableTo(self.disposeBag)
    }
    
    // MARK: Private

    private var viewModelObserver: AnyObserver<SessionViewModel?> {
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
            self.subtitle.text = viewModel.subtitle
        }
    }

}
