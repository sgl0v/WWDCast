//
//  SessionDetailsPresenterImpl.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 06/07/16.
//  Copyright © 2016 Maksym Shcheglov. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class SessionDetailsViewModel: SessionDetailsViewModelType {
    private let disposeBag = DisposeBag()
    private let useCase: SessionDetailsUseCaseType

    init(useCase: SessionDetailsUseCaseType) {
        self.useCase = useCase
    }

    // MARK: SessionDetailsViewModel

    func transform(input: SessionDetailsViewModelInput) -> SessionDetailsViewModelOutput {
        let errorTracker = ErrorTracker()

        let sessionObservable = input.load.flatMapLatest {
            self.useCase.session
                .trackError(errorTracker)
                .asDriverOnErrorJustComplete()
        }
        let favoriteObservable = input.toggleFavorite.flatMap({_ in
            self.useCase.toggle
                .trackError(errorTracker)
                .asDriverOnErrorJustComplete()
        }).withLatestFrom(sessionObservable)

        let session = Driver.merge(sessionObservable, favoriteObservable)
            .map(SessionItemViewModelBuilder.build)

        let devices = input.showDevices.flatMap({ _ in
            return self.useCase.devices.map({ devices in
                return devices.map({ $0.description })
            })
                .trackError(errorTracker)
                .asDriverOnErrorJustComplete()
        })

        let playback = input.startPlayback.asObservable()
            .withLatestFrom(self.useCase.devices) { (index, devices) -> GoogleCastDevice in
                return devices[index]
            }
            .flatMap(self.useCase.play)
            .trackError(errorTracker)
            .asDriverOnErrorJustComplete()

        let error = errorTracker.asDriver()

        return SessionDetailsViewModelOutput(session: session, devices: devices, playback: playback, error: error)
    }

}
