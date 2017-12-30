//
//  SessionsSearchViewModelImpl.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 04/07/16.
//  Copyright © 2016 Maksym Shcheglov. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class SessionsSearchViewModel: SessionsSearchViewModelType {

    private let useCase: SessionsSearchUseCaseType
    private weak var navigator: SessionsSearchNavigator?
    private let disposeBag = DisposeBag()

    init(useCase: SessionsSearchUseCaseType, navigator: SessionsSearchNavigator) {
        self.useCase = useCase
        self.navigator = navigator
    }

    // MARK: SessionsSearchViewModelType

    func transform(input: SessionsSearchViewModelInput) -> SessionsSearchViewModelOuput {
        let errorTracker = ErrorTracker()
        let activityIndicator = ActivityIndicator()

        let sessionsTrigger = Driver.merge(input.loading.map({ "" }), input.search)
        let sessions: Driver<[SessionSectionViewModel]> = sessionsTrigger.flatMapLatest {query in
                self.useCase.search(with: query)
                .map(SessionSectionViewModelBuilder.build)
                .trackError(errorTracker)
                .asDriverOnErrorJustComplete()
        }

        input.selection.map({ session in
            return session.id
        }).drive(onNext: self.navigator?.showDetails).addDisposableTo(self.disposeBag)

        input.filter.drive(onNext: self.navigator?.showFilter).addDisposableTo(self.disposeBag)

        let error = errorTracker.asDriver()
        let loading = activityIndicator.asDriver()

        return SessionsSearchViewModelOuput(sessions: sessions,
                                            loading: loading,
                                            error: error)

    }
}
