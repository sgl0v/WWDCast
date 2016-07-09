//
//  SchedulerService.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 09/07/16.
//  Copyright © 2016 Maksym Shcheglov. All rights reserved.
//

import Foundation
import RxSwift

protocol SchedulerService: class {

    var backgroundWorkScheduler: ImmediateSchedulerType { get }
    var mainScheduler: MainScheduler { get }

}
