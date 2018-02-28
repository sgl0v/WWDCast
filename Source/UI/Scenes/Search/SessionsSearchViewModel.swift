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

        let initialSessions: Driver<[SessionSectionViewModel]> = input.loading.flatMap {
            return self.useCase.sessions
                .map(SessionSectionViewModelBuilder.build)
                .trackError(errorTracker)
                .asDriverOnErrorJustComplete()
        }
        let searchSessions: Driver<[SessionSectionViewModel]> = input.search.flatMapLatest {query in
                return self.useCase.search(with: query)
                .map(SessionSectionViewModelBuilder.build)
                .trackError(errorTracker)
                .asDriverOnErrorJustComplete()
        }
        let sessions = Driver.merge(initialSessions, searchSessions).distinctUntilChanged(==)

        input.selection.map({ session in
            return session.id
        }).drive(onNext: self.navigator?.showDetails).disposed(by: self.disposeBag)

        input.filter.drive(onNext: self.navigator?.showFilter).disposed(by: self.disposeBag)

        let error = errorTracker.asDriver()
        let loading = activityIndicator.asDriver()

        return SessionsSearchViewModelOuput(sessions: sessions,
                                            loading: loading,
                                            error: error)

    }
}
