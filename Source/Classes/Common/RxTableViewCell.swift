//
//  RxTableViewCell.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 05/07/16.
//  Copyright © 2016 Maksym Shcheglov. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class RxTableViewCell: UITableViewCell {
    var onPrepareForReuse: Observable<Void> {
        return _onPrepareForReuse
    }
    var onSelected: Observable<Void> {
        return _onSelected
    }
    private let _onPrepareForReuse = PublishSubject<Void>()
    private let _onSelected = PublishSubject<Void>()

    override func prepareForReuse() {
        super.prepareForReuse()
        _onPrepareForReuse.onNext()
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if (selected) {
            _onSelected.onNext()
        }
    }
}

extension RxTableViewCell {
    
    var rx_accessoryCheckmark: ControlProperty<Bool> {
        let getter: UITableViewCell -> Bool = { cell in
            cell.accessoryType == .Checkmark
        }
        let setter: (UITableViewCell, Bool) -> Void = { cell, selected in
            cell.accessoryType = selected ? .Checkmark : .None
        }
        let values: Observable<Bool> = Observable.deferred { [weak self] in
            guard let existingSelf = self else {
                return Observable.empty()
            }
            
            return existingSelf.onSelected.map({ _ in true }).startWith(getter(existingSelf))
        }
        return ControlProperty(values: values, valueSink: UIBindingObserver(UIElement: self) { control, value in
            setter(control, value)
            })
    }
}
