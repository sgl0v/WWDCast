//
//  Session+Track.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 05/06/2018.
//  Copyright © 2018 Maksym Shcheglov. All rights reserved.
//

import Foundation

extension Session {

    enum Track: Int {
        case featured, media, developerTools, graphicsAndGames, frameworks, design, distribution
    }
}

extension Session.Track {
        static let all: [Session.Track] = [.featured, .media, .developerTools, .graphicsAndGames, .frameworks, .design, .distribution]

        func topics() -> Set<Session.Topic> {
            switch self {
            case .featured:
                return [.specialEvents, .lunchtimeSessions]
            case .media:
                return [.audio, .camera, .photosAndImaging, .video]
            case .developerTools:
                return [.compilerAndLLVM, .debugging, .interfaceBuilder, .performance, .swift, .testing, .xcode]
            case .graphicsAndGames:
                return [.ARVR, .graphics2D, .graphics3D, .games, .metal]
            case .frameworks:
                return [.accessibility, .accessories, .applePayAndWallet, .businessAndEnterprise, .carPlay, .cloudAndLocalStorage,
                        .educationAndKids, .extensions, .foundation, .healthAndFitness, .homeKit, .internationalizationAndLocalization,
                        .machineLearningAndVision, .mapsAndLocation, .networking, .privacyAndSecurity, .safariAndWeb, .siriAndVoice,
                        .uiFrameworks]
            case .design:
                return [.interactionDesign, .prototyping, .soundAndHaptics, .visualDesign, .typography]
            case .distribution:
                return [.businessModels, .certificatesAndSigning, .communityManagement, .deviceManagement, .inAppPurchaseAndSubscriptions,
                        .appStoreConnect, .marketing]
        }
    }
}

extension Session.Track: Comparable { }

func < (lhs: Session.Track, rhs: Session.Track) -> Bool {
    return lhs.rawValue > rhs.rawValue
}

extension Session.Track: CustomStringConvertible {

    var description: String {
        let mapping: [Session.Track: String] = [.frameworks: "Frameworks",
                                                .developerTools: "Developer Tools", .featured: "Featured", .graphicsAndGames: "Graphics and Games",
                                                .design: "Design", .media: "Media", .distribution: "App Store and Distribution"]
        let localizationKey = mapping[self] ?? ""
        return NSLocalizedString(localizationKey, comment: "Track description")
    }
}

extension Sequence where Iterator.Element == Session.Track {

    var hashValue: Int {
        let hash = 5381
        return self.reduce(hash, { acc, track in
            return acc ^ track.hashValue
        })
    }

    var description: String {
        let trackDescriptions: [String] = self.map({ track in
            return track.description
        })
        return trackDescriptions.joined(separator: ", ")
    }
}
