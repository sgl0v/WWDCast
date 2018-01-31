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

    override func awakeFromNib() {
        super.awakeFromNib()
        self.layoutMargins = UIEdgeInsets.zero
        self.separatorInset = UIEdgeInsets.zero
    }

    // MARK: SessionTableViewCell
    typealias ViewModel = FilterItemViewModel

    func bind(to viewModel: ViewModel) {
        self.textLabel?.text = viewModel.title
        switch viewModel.style {
        case .switch:
            self.accessoryType = .none
            self.switchAccessoryView.isOn = viewModel.selected
        case .checkmark:
            self.accessoryView = nil
            self.accessoryType = viewModel.selected ? .checkmark : .none
        }
    }

    private var switchAccessoryView: UISwitch {
        if let switchButton = self.accessoryView as? UISwitch {
            return switchButton
        }
        let switchButton = UISwitch()
        switchButton.isUserInteractionEnabled = false
        self.accessoryView = switchButton
        return switchButton
    }

}
