//
//  SessionItemViewModelBuilder.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 27/07/16.
//  Copyright © 2016 Maksym Shcheglov. All rights reserved.
//

import Foundation

struct SessionItemViewModelBuilder {

    static func build(session: Session) -> SessionItemViewModel {
        let focus = session.platforms.map({ $0.rawValue }).joinWithSeparator(", ")
        let subtitle = ["\(session.year)", "Session \(session.id)", focus].filter({ $0.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 0}) .joinWithSeparator(" · ")
        return SessionItemViewModel(uniqueID: session.uniqueId, title: session.title, subtitle: subtitle, summary: session.summary, thumbnailURL: session.shelfImageURL)
    }

    static func build(sessions: [Session]) -> [SessionSectionViewModel] {
        let sessions: [SessionSectionViewModel] = Track.allTracks.map( { track in
            let sessions = sessions.filter({ session in session.track == track }).map(self.build)
            return SessionSectionViewModel(title: track.rawValue, items: sessions)
        }).filter({ SessionSectionViewModel in
            return !SessionSectionViewModel.items.isEmpty
        })
        return sessions
    }

}