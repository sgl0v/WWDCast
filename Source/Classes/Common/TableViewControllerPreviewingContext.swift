//
//  TableViewControllerPreviewCoordinator.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 30/11/2016.
//  Copyright © 2016 Maksym Shcheglov. All rights reserved.
//

import UIKit

struct TableViewControllerPreviewingContext<RowViewModel> {
    typealias Item = RowViewModel
    
    let previewControllerForItem: (RowViewModel) -> UIViewController?
    let commitPreview: (UIViewController) -> Void
    
    init(previewControllerForItem: @escaping (RowViewModel) -> UIViewController?, commitPreview: @escaping (UIViewController) -> Void) {
        self.previewControllerForItem = previewControllerForItem
        self.commitPreview = commitPreview
    }
}
