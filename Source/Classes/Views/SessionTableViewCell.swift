//
//  SessionTableViewCell.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 05/07/16.
//  Copyright © 2016 Maksym Shcheglov. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class SessionTableViewCell: RxTableViewCell, ReusableView, BindableView, NibProvidable {
    @IBOutlet weak var thumbnailImage: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var summary: UILabel!
//}
//
//extension SessionTableViewCell: BindableView {
    typealias ViewModel = SessionItemViewModel

    func bindViewModel(_ viewModel: ViewModel) {
        self.title.text = viewModel.title
        self.summary.text = viewModel.summary
        _ = Observable.just(viewModel.thumbnailURL)
            .asObservable()
            .takeUntil(self.onPrepareForReuse)
            .bindTo(self.thumbnailImage.rx.imageURL)
        self.layoutMargins = UIEdgeInsets.zero
        self.separatorInset = UIEdgeInsets.zero
    }
}
