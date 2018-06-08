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
        let viewModelBuilder = SessionSectionViewModelBuilder(imageLoader: self.useCase.loadImage)
        let errorTracker = ErrorTracker()

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

        input.filter.drive(onNext: { [weak self] in
            guard let navigator = self?.navigator else {
                return
            }
            navigator.showFilter()
        }).disposed(by: self.disposeBag)

        let error = errorTracker.asDriver()
        let loading = sessions.map({ _ in false }).startWith(true)
        let empty = sessions.map({ sessions in
            return sessions.isEmpty
        }).startWith(false)

        return SessionsSearchViewModelOuput(sessions: sessions,
                                            loading: loading,
                                            empty: empty,
                                            error: error)

    }
}
