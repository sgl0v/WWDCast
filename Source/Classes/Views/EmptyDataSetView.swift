//
//  EmptyDataSetView.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 08/11/2016.
//  Copyright © 2016 Maksym Shcheglov. All rights reserved.
//

import UIKit

class EmptyDataSetView: UIView, NibProvidable {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    static func view() -> EmptyDataSetView {
        return Bundle.init(for: self).loadNibNamed(self.nibName, owner: nil, options: nil)?.first as! EmptyDataSetView
    }
}
