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
        self.layoutMargins = UIEdgeInsetsZero
        self.separatorInset = UIEdgeInsetsZero
    }
    
    // MARK: SessionTableViewCell
    typealias ViewModel = FilterItemViewModel
    
    func bindViewModel(viewModel: ViewModel) {
        let disposeBag = DisposeBag()
        self.onPrepareForReuse.subscribeNext({[unowned self] in
            self.disposeBag = nil
            self.accessoryView = nil
            self.accessoryType = .None
            }).addDisposableTo(disposeBag)
        
        self.textLabel?.text = viewModel.title
        
        if case .Switch = viewModel.style {
            let switchButton = UISwitch()
            (switchButton.rx_value <-> viewModel.selected).addDisposableTo(disposeBag)
            self.accessoryView = switchButton
        } else {
            (self.rx_accessoryCheckmark <-> viewModel.selected).addDisposableTo(disposeBag)
        }
        
        self.disposeBag = disposeBag
    }
    
}
