//
//  TabBarController.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 20/10/2016.
//  Copyright © 2016 Maksym Shcheglov. All rights reserved.
//

import Foundation
import GoogleCast

/// The UITabBarController with GoogleCast media controls on top of the UITabBar
class TabBarController: UITabBarController, GCKUIMiniMediaControlsViewControllerDelegate {

    private var miniMediaControlsViewController: GCKUIMiniMediaControlsViewController!
    private static let kMiniMediaControlsViewHeight: CGFloat = 64.0

    override func viewDidLoad() {
        super.viewDidLoad()

        let castContext = GCKCastContext.sharedInstance()
        castContext.useDefaultExpandedMediaControls = true

        miniMediaControlsViewController = castContext.createMiniMediaControlsViewController()
        miniMediaControlsViewController.delegate = self
        self.addChildViewController(miniMediaControlsViewController)
        self.view.addSubview(miniMediaControlsViewController.view)
        miniMediaControlsViewController.didMove(toParentViewController: self)
        miniMediaControlsViewController.view.isHidden = !miniMediaControlsViewController.active
    }

    func miniMediaControlsViewController(_ miniMediaControlsViewController: GCKUIMiniMediaControlsViewController, shouldAppear: Bool) {
        miniMediaControlsViewController.view.isHidden = !miniMediaControlsViewController.active
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let y = self.view.bounds.maxY - TabBarController.kMiniMediaControlsViewHeight - self.tabBar.frame.height
        miniMediaControlsViewController.view.frame = CGRect(x: 0, y: y, width: self.view.bounds.width, height: TabBarController.kMiniMediaControlsViewHeight)
    }
}
