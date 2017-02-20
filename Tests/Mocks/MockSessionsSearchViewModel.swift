//
//  MockSessionsSearchViewModel.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 18/02/2017.
//  Copyright © 2017 Maksym Shcheglov. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
@testable import WWDCast

class MockSessionsSearchViewModel: SessionsSearchViewModelProtocol {

    func didSelect(item: SessionItemViewModel) {

    }

    func didTapFilter() {

    }

    func didStartSearch(withQuery query: String) {

    }

    var isLoading: Driver<Bool> {
        return Observable.empty().asDriver(onErrorJustReturn: false)
    }

    var title: Driver<String> {
        return Observable.empty().asDriver(onErrorJustReturn: "")
    }

    var sessionSections: Driver<[SessionSectionViewModel]> {
        return Observable.empty().asDriver(onErrorJustReturn: [])
    }

}
