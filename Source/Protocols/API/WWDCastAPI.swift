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
    
    func sessions() -> Observable<[Session]>
    
    func play(session: Session, onDevice device: GoogleCastDevice) -> Observable<Void>
    
    func addToFavorites(session: Session) -> Observable<Session>
    
    func removeFromFavorites(session: Session) -> Observable<Session>
}
