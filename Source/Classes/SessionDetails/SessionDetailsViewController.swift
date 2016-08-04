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
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var header: UILabel!
    @IBOutlet weak var summary: UILabel!
    @IBOutlet weak var subtitle: UILabel!

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

//        let blurEffect = UIBlurEffect(style: .ExtraLight)
//        let blurEffectView = UIVisualEffectView(effect: blurEffect)
//        //always fill the view
//        blurEffectView.frame = self.image.bounds
//        blurEffectView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
//        self.image.addSubview(blurEffectView)
    
        
        let image = UIImage(named: "play_circle")?.imageWithRenderingMode(.AlwaysTemplate)
        self.playButton.setImage(image, forState: .Normal)
        self.playButton.tintColor = UIColor.whiteColor()

        self.presenter.session.drive(self.viewModelObserver)
            .addDisposableTo(self.disposeBag)
        self.playButton.rx_tap.map({ _ in }).bindTo(self.presenter.playSession)
            .addDisposableTo(disposeBag)
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
            self.subtitle.text = viewModel.subtitle
        }
    }

}

extension SessionDetailsViewController: SessionDetailsView {

}
