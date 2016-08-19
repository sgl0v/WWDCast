//
//  SessionViewModelBuilder.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 27/07/16.
//  Copyright © 2016 Maksym Shcheglov. All rights reserved.
//

import Foundation

struct SessionViewModelBuilder {

    static func build(session: Session) -> SessionViewModel {
        let focus = session.platforms.map({ $0.rawValue }).joinWithSeparator(", ")
        let subtitle = ["WWDC \(session.year)", "Session \(session.id)", focus].filter({ $0.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 0}) .joinWithSeparator(" · ")
        return SessionViewModel(uniqueID: session.uniqueId, title: session.title, subtitle: subtitle, summary: session.summary, thumbnailURL: session.shelfImageURL)
    }

    static func build(sessions: [Session]) -> [SessionViewModels] {
        let sessions: [SessionViewModels] = Track.allTracks.map( { track in
            let sessions = sessions.filter({ session in session.track == track }).map(self.build)
            return SessionViewModels(title: track.rawValue, items: sessions)
        }).filter({ sessionViewModels in
            return !sessionViewModels.items.isEmpty
        })
        return sessions
    }

}