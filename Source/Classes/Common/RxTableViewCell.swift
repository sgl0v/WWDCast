//
//  RxTableViewCell.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 05/07/16.
//  Copyright © 2016 Maksym Shcheglov. All rights reserved.
//

import UIKit
import RxSwift

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
