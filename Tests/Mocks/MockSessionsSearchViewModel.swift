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

class MockSessionsSearchViewModel: SessionsSearchViewModelType {

    typealias SelectObserver = (SessionItemViewModel) -> Void
    typealias FilterTapObserver = () -> Void
    typealias SearchStartObserver = (String) -> Void
    typealias LoadingObservable = Observable<Bool>
    typealias TitleObservable = Observable<String>
    typealias SessionsObservable = Observable<[SessionSectionViewModel]>

    var selectObserver: SelectObserver?
    var filterTapObserver: FilterTapObserver?
    var searchStartObserver: SearchStartObserver?
    var loadingObservable: LoadingObservable?
    var titleObservable: TitleObservable?
    var sessionsObservable: SessionsObservable?

    func didSelect(item: SessionItemViewModel) {
        guard let observer = self.selectObserver else {
            fatalError("Not implemented")
        }
        observer(item)
    }

    func didTapFilter() {
        guard let observer = self.filterTapObserver else {
            fatalError("Not implemented")
        }
        observer()
    }

    func didStartSearch(withQuery query: String) {
        guard let observer = self.searchStartObserver else {
            fatalError("Not implemented")
        }
        observer(query)
    }

    var isLoading: Driver<Bool> {
        guard let observable = self.loadingObservable else {
            fatalError("Not implemented")
        }
        return observable.asDriver(onErrorJustReturn: false)
    }

    var title: Driver<String> {
        guard let observable = self.titleObservable else {
            fatalError("Not implemented")
        }
        return observable.asDriver(onErrorJustReturn: "")
    }

    var sessionSections: Driver<[SessionSectionViewModel]> {
        guard let observable = self.sessionsObservable else {
            fatalError("Not implemented")
        }
        return observable.asDriver(onErrorJustReturn: [])
    }

}
