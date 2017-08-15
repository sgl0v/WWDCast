//
//  GCKMediaInformation.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 18/11/2016.
//  Copyright © 2016 Maksym Shcheglov. All rights reserved.
//

import Foundation
import GoogleCast

extension GoogleCastMedia {

    var gckMedia: GCKMediaInformation {
        let metadata = GCKMediaMetadata(metadataType: .generic)
        metadata.setString(self.title, forKey: kGCKMetadataKeyTitle)
        metadata.setString(self.subtitle, forKey: kGCKMetadataKeySubtitle)
        metadata.addImage(GCKImage(url: self.thumbnail, width: 734, height: 413))
        let mediaTrack = GCKMediaTrack(identifier: self.id.hashValue, contentIdentifier: self.captions,
                                       contentType: "text/vtt", type: .text, textSubtype: .captions,
                                       name: "English Captions", languageCode: "en", customData: nil)

        return GCKMediaInformation(contentID: self.video, streamType: .none, contentType: "video/mp4",
                                   metadata: metadata, streamDuration: 0, mediaTracks: [mediaTrack],
                                   textTrackStyle: GCKMediaTextTrackStyle.createDefault(), customData: nil)
    }
}
