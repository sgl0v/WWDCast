//
//  UIBarButtonItem_Common.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 03/08/16.
//  Copyright © 2016 Maksym Shcheglov. All rights reserved.
//

import Foundation
import GoogleCast

extension UIBarButtonItem {

    static func castBarButtonItem() -> UIBarButtonItem {
        let castButton = GCKUICastButton(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
        castButton.tintColor = UIColor.black
        return UIBarButtonItem(customView: castButton)
    }

}
