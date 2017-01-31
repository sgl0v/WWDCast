//
//  SessionItemViewModelBuilder.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 27/07/16.
//  Copyright © 2016 Maksym Shcheglov. All rights reserved.
//

import Foundation

struct SessionItemViewModelBuilder {

    static func build(_ session: Session) -> SessionItemViewModel {
        return SessionItemViewModel(uniqueID: session.uniqueId, title: session.title,
                                    subtitle: session.subtitle, summary: session.summary, thumbnailURL: session.thumbnail,
                                    favorite: session.favorite)
    }
}

struct SessionSectionViewModelBuilder {

    static func build(_ sessions: [Session]) -> [SessionSectionViewModel] {
        let sessions: [SessionSectionViewModel] = Session.Track.all.map({ track in
            let sessions = sessions.filter({ session in session.track == track }).map(SessionItemViewModelBuilder.build)
            return SessionSectionViewModel(title: track.description, items: sessions)
        }).filter({ SessionSectionViewModel in
            return !SessionSectionViewModel.items.isEmpty
        })
        return sessions
    }

}
