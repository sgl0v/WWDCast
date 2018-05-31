//
//  SessionItemViewModelBuilder.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 27/07/16.
//  Copyright © 2016 Maksym Shcheglov. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

struct SessionItemViewModelBuilder {

    typealias ImageLoader = (URL) -> Observable<UIImage>
    private let imageLoader: ImageLoader

    init(imageLoader: @escaping ImageLoader) {
        self.imageLoader = imageLoader
    }

    func build(_ session: Session) -> SessionItemViewModel {
        let thumbnail = self.imageLoader(session.thumbnail)
        return SessionItemViewModel(id: session.id, title: session.title,
                                    subtitle: session.subtitle, summary: session.summary, thumbnail: thumbnail, favorite: session.favorite)
    }

}

struct SessionSectionViewModelBuilder {

    private let imageLoader: SessionItemViewModelBuilder.ImageLoader

    init(imageLoader: @escaping SessionItemViewModelBuilder.ImageLoader) {
        self.imageLoader = imageLoader
    }

    func build(_ sessions: [Session]) -> [SessionSectionViewModel] {
        let itemBuilder = SessionItemViewModelBuilder(imageLoader: self.imageLoader)
        let sessions: [SessionSectionViewModel] = Session.Track.all.map({ track in
            let sessions = sessions.sorted().filter({ session in session.track == track }).map(itemBuilder.build)
            return SessionSectionViewModel(title: track.description, items: sessions)
        }).filter({ sessionSectionViewModel in
            return !sessionSectionViewModel.items.isEmpty
        })
        return sessions
    }

}
