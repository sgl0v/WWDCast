//
//  FilterTableViewCell.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 27/09/2016.
//  Copyright © 2016 Maksym Shcheglov. All rights reserved.
//

import UIKit
import RxSwift

class FilterTableViewCell: RxTableViewCell, ReusableView, BindableView, NibProvidable {

    var disposeBag: DisposeBag?

    override func awakeFromNib() {
        super.awakeFromNib()
        self.layoutMargins = UIEdgeInsets.zero
        self.separatorInset = UIEdgeInsets.zero
    }

    // MARK: SessionTableViewCell
    typealias ViewModel = FilterItemViewModel

    func bind(viewModel: ViewModel) {
        let disposeBag = DisposeBag()
        self.onPrepareForReuse.subscribe(onNext: {[unowned self] in
            self.disposeBag = nil
            self.accessoryView = nil
            self.accessoryType = .none
            }).addDisposableTo(disposeBag)

        self.textLabel?.text = viewModel.title

        if case .switch = viewModel.style {
            let switchButton = UISwitch()
            (switchButton.rx.value <-> viewModel.selected).addDisposableTo(disposeBag)
            self.accessoryView = switchButton
        } else {
            (self.rx.accessoryCheckmark <-> viewModel.selected).addDisposableTo(disposeBag)
        }

        self.disposeBag = disposeBag
    }

}
