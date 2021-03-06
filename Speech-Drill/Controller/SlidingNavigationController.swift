//
//  SlidingNavigationController.swift
//  Speech-Drill
//
//  Created by Parth Tamane on 24/01/21.
//  Copyright © 2021 Parth Tamane. All rights reserved.
//

import Foundation
import UIKit

class SlidingNavigationController:UINavigationController, UIGestureRecognizerDelegate, UINavigationControllerDelegate{
    
    let revealSideNav = RevealSideNav()
    
    override func viewDidLoad() {
        logger.info("Loaded SlidingNavigationController view")

        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = self
        delegate = self
        navigationBar.titleTextAttributes = [NSAttributedStringKey.font: getFont(name: .HelveticaNeueBold, size: .xlarge)]
        //Add a defualt hamburger buttons whose onclick is modified by child vcs
    }
    
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        logger.info("Disabling interactive pop on view controller push")
        
        super.pushViewController(viewController, animated: animated)
        interactivePopGestureRecognizer?.isEnabled = false
    }
    
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        logger.info("Enabling interactive pop on view controller show")

        interactivePopGestureRecognizer?.isEnabled = true
    }
    
    // IMPORTANT: without this if you attempt swipe on
    // first view controller you may be unable to push the next one
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        logger.info("Setting when to begin gesture resognizer for sidenav")
        
        return viewControllers.count > 1
    }
    
    //    func navigationController(
    //        _ navigationController: UINavigationController,
    //        animationControllerFor operation: UINavigationControllerOperation,
    //        from fromVC: UIViewController,
    //        to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    //
    //        revealSideNav.pushStyle = operation == .push
    //        return revealSideNav
    //    }
}
