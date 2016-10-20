//
//  TabBarController.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 20/10/2016.
//  Copyright © 2016 Maksym Shcheglov. All rights reserved.
//

import Foundation
import GoogleCast

// The UITabBarController with GoogleCast media controls on top of the UITabBar
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
        miniMediaControlsViewController.didMoveToParentViewController(self)
        miniMediaControlsViewController.view.hidden = !miniMediaControlsViewController.active
    }
    
    func miniMediaControlsViewController(miniMediaControlsViewController: GCKUIMiniMediaControlsViewController, shouldAppear: Bool) {
        miniMediaControlsViewController.view.hidden = !miniMediaControlsViewController.active
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let y = CGRectGetMaxY(self.view.bounds) - TabBarController.kMiniMediaControlsViewHeight - CGRectGetHeight(self.tabBar.frame)
        miniMediaControlsViewController.view.frame = CGRectMake(0, y, CGRectGetWidth(self.view.bounds), TabBarController.kMiniMediaControlsViewHeight)
    }
}
