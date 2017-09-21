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

    static func build(_ session: Session) -> SessionItemViewModel {

        return SessionItemViewModel(id: session.id, title: session.title,
                                    subtitle: session.subtitle, summary: session.summary, thumbnailURL: session.thumbnail,
                                    thumbnailPlaceholder: thumbnail(for: session.type), favorite: session.favorite)
    }

    private static func thumbnail(`for` sessionType: Session.EventType) -> UIImage {
        switch sessionType {
        case .video:
            return #imageLiteral(resourceName: "video-event")
        case .session:
            return #imageLiteral(resourceName: "session-event")
        case .lab:
            return #imageLiteral(resourceName: "lab-event")
        case .specialEvent:
            return #imageLiteral(resourceName: "special-event")
        case .getTogether:
            return #imageLiteral(resourceName: "get-together-event")
        }
    }

}

struct SessionSectionViewModelBuilder {

    static func build(_ sessions: [Session]) -> [SessionSectionViewModel] {
        let sessions: [SessionSectionViewModel] = Session.Track.all.map({ track in
            let sessions = sessions.sorted().filter({ session in session.track == track }).map(SessionItemViewModelBuilder.build)
            return SessionSectionViewModel(title: track.description, items: sessions)
        }).filter({ sessionSectionViewModel in
            return !sessionSectionViewModel.items.isEmpty
        })
        return sessions
    }

}
