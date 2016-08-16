//
//  UIBarButtonItem_Common.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 03/08/16.
//  Copyright © 2016 Maksym Shcheglov. All rights reserved.
//

import Foundation
import GoogleCast

func castBarButtonItem() -> UIBarButtonItem {
    let castButton = GCKUICastButton(frame: CGRectMake(0, 0, 24, 24))
    castButton.tintColor = UIColor.blackColor()
    return UIBarButtonItem(customView: castButton)
}
