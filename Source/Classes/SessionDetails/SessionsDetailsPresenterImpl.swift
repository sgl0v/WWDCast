//
//  SessionsDetailsPresenterImpl.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 06/07/16.
//  Copyright © 2016 Maksym Shcheglov. All rights reserved.
//

import UIKit
import RxSwift

class SessionDetailsPresenterImpl {
    weak var view: SessionDetailsView!
    var interactor: SessionDetailsInteractor!
    private let disposeBag = DisposeBag()

    init(view: SessionDetailsView) {
        self.view = view
    }
}

extension SessionDetailsPresenterImpl: SessionDetailsPresenter {

}
