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
        let metadata = GCKMediaMetadata(metadataType: .movie)
        metadata.setString(self.title, forKey: kGCKMetadataKeyTitle)
        metadata.setString(self.subtitle, forKey: kGCKMetadataKeySubtitle)
        metadata.addImage(GCKImage(url: self.thumbnail, width: 734, height: 413))

        return GCKMediaInformation(contentID: self.video, streamType: .none, contentType: "videos/mp4",
                                   metadata: metadata, streamDuration: self.duration, mediaTracks: [],
                                   textTrackStyle: GCKMediaTextTrackStyle.createDefault(), customData: nil)
    }
}
