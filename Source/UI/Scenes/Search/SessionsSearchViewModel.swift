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
    private let imageLoadUseCase: ImageLoadUseCaseType
    private weak var navigator: SessionsSearchNavigator?
    private let disposeBag = DisposeBag()

    init(useCase: SessionsSearchUseCaseType, imageLoadUseCase: ImageLoadUseCaseType, navigator: SessionsSearchNavigator) {
        self.useCase = useCase
        self.imageLoadUseCase = imageLoadUseCase
        self.navigator = navigator
    }

    // MARK: SessionsSearchViewModelType

    func transform(input: SessionsSearchViewModelInput) -> SessionsSearchViewModelOuput {
        let viewModelBuilder = SessionSectionViewModelBuilder(imageLoadUseCase: self.imageLoadUseCase)
        let errorTracker = ErrorTracker()
        let activityIndicator = ActivityIndicator()

        let initialSessions: Driver<[SessionSectionViewModel]> = input.appear.flatMap({_ in
            return self.useCase.sessions
                .map(viewModelBuilder.build)
                .takeUntil(input.disappear.asObservable())
                .trackError(errorTracker)
                .asDriverOnErrorJustComplete()
        })
        let searchSessions: Driver<[SessionSectionViewModel]> = input.search.flatMapLatest {query in
                return self.useCase.search(with: query)
                .map(viewModelBuilder.build)
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
