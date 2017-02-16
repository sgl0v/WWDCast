//
//  EmptyDataSetView.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 08/11/2016.
//  Copyright © 2016 Maksym Shcheglov. All rights reserved.
//

import UIKit

class EmptyDataSetView: UIView, NibProvidable, BindableView {

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!

    static func view() -> EmptyDataSetView {
        if let view = Bundle.init(for: self).loadNibNamed(self.nibName, owner: nil, options: nil)?.first as? EmptyDataSetView {
            return view
        }
        fatalError("Failed to load the view from nib file with name: \(self.nibName)")
    }

    typealias ViewModel = EmptyDataSetViewModel

    func bind(with viewModel: ViewModel) {
        self.titleLabel.text = viewModel.title
        self.descriptionLabel.text = viewModel.description
    }
}
