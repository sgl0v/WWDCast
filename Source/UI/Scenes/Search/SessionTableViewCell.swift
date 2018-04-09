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

class SessionTableViewCell: RxTableViewCell, ReusableView, NibProvidable {
    @IBOutlet private weak var thumbnailImage: UIImageView!
    @IBOutlet private weak var title: UILabel!
    @IBOutlet private weak var summary: UILabel!
    private var disposeBag = DisposeBag()

    override public func prepareForReuse() {
        super.prepareForReuse()
        self.thumbnailImage?.image = nil
        self.disposeBag = DisposeBag()
    }

}

extension SessionTableViewCell: BindableView {
    typealias ViewModel = SessionItemViewModel

    func bind(to viewModel: ViewModel) {
        self.title.text = viewModel.title
        self.summary.text = viewModel.summary
        viewModel.thumbnail
            .asDriver(onErrorJustReturn: UIImage())
            .drive(self.thumbnailImage.rx.image)
            .disposed(by: self.disposeBag)
        self.layoutMargins = UIEdgeInsets.zero
        self.separatorInset = UIEdgeInsets.zero
    }
}
