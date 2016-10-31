//
//  WWDCastAPI.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 25/09/2016.
//  Copyright © 2016 Maksym Shcheglov. All rights reserved.
//

import Foundation
import RxSwift

protocol WWDCastAPI: class {

    var devices: [GoogleCastDevice] { get }
    
    var sessions: Observable<[Session]> { get }
    
    func session(withId id: String) -> Observable<Session>
    
    func play(session: Session, onDevice device: GoogleCastDevice) -> Observable<Void>
    
    var favoriteSessions: Observable<[Session]> { get }
    
    func toggleFavorite(session: Session) -> Observable<Session>
    
}
