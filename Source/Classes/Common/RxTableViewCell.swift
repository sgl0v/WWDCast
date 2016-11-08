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
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if (selected) {
            _onSelected.onNext()
        }
    }
}

extension Reactive where Base: RxTableViewCell {

    var accessoryCheckmark: ControlProperty<Bool> {
        let getter: (UITableViewCell) -> Bool = { cell in
            cell.accessoryType == .checkmark
        }
        let setter: (UITableViewCell, Bool) -> Void = { cell, selected in
            cell.accessoryType = selected ? .checkmark : .none
        }
        let values: Observable<Bool> = Observable.deferred { [weak base] in
            guard let existingBase = base else {
                return Observable.empty()
            }
            
            return existingBase.onSelected.map({ _ in true }).startWith(getter(existingBase))
        }
        let valueSink = UIBindingObserver(UIElement: base) { control, value in
            setter(control, value)
        }
        return ControlProperty(values: values, valueSink: valueSink)
    }
}
