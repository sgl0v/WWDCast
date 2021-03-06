//
//  EmptyDataSetView.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 08/11/2016.
//  Copyright © 2016 Maksym Shcheglov. All rights reserved.
//

import UIKit

class EmptyDataSetView: UIView, NibProvidable {

    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!

    static func view(_ title: String, description: String, image: UIImage) -> EmptyDataSetView {
        guard let view = Bundle.init(for: self).loadNibNamed(self.nibName, owner: nil, options: nil)?.first as? EmptyDataSetView else {
            fatalError("Failed to load the view from nib file with name: \(self.nibName)")
        }
        view.titleLabel.text = title
        view.descriptionLabel.text = description
        view.imageView.image = image
        return view
    }
}
