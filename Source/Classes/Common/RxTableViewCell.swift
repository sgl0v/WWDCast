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
    private let _onPrepareForReuse = PublishSubject<Void>()

    override func prepareForReuse() {
        super.prepareForReuse()
        _onPrepareForReuse.onNext()
    }
}
