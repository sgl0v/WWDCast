//
//  NetworkService.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 09/07/16.
//  Copyright © 2016 Maksym Shcheglov. All rights reserved.
//

import Foundation
import RxSwift

protocol NetworkService: class {

    func GET<Type, Builder: EntityBuilder where Builder.EntityType == Type>(URLString: String, parameters: [String: AnyObject], builder: Builder) -> Observable<Type>
}
