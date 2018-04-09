//
//  SessionItemViewModelBuilder.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 27/07/16.
//  Copyright © 2016 Maksym Shcheglov. All rights reserved.
//

import Foundation
import UIKit

struct SessionItemViewModelBuilder {

    private let imageLoadUseCase: ImageLoadUseCaseType

    init(imageLoadUseCase: ImageLoadUseCaseType) {
        self.imageLoadUseCase = imageLoadUseCase
    }

    func build(_ session: Session) -> SessionItemViewModel {
        let thumbnail = self.imageLoadUseCase.loadImage(for: session.thumbnail)
        return SessionItemViewModel(id: session.id, title: session.title,
                                    subtitle: session.subtitle, summary: session.summary, thumbnail: thumbnail, favorite: session.favorite)
    }

}

struct SessionSectionViewModelBuilder {

    private let imageLoadUseCase: ImageLoadUseCaseType

    init(imageLoadUseCase: ImageLoadUseCaseType) {
        self.imageLoadUseCase = imageLoadUseCase
    }

    func build(_ sessions: [Session]) -> [SessionSectionViewModel] {
        let itemBuilder = SessionItemViewModelBuilder(imageLoadUseCase: self.imageLoadUseCase)
        let sessions: [SessionSectionViewModel] = Session.Track.all.map({ track in
            let sessions = sessions.sorted().filter({ session in session.track == track }).map(itemBuilder.build)
            return SessionSectionViewModel(title: track.description, items: sessions)
        }).filter({ sessionSectionViewModel in
            return !sessionSectionViewModel.items.isEmpty
        })
        return sessions
    }

}
