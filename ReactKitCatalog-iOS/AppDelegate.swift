//
//  AppDelegate.swift
//  ReactKitCatalog-iOS
//
//  Created by Yasuhiro Inami on 2014/10/06.
//  Copyright (c) 2014年 Yasuhiro Inami. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate {

    var window: UIWindow?
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool
    {
        let splitVC = self.window!.rootViewController as UISplitViewController
        splitVC.delegate = self
        
        let mainNavC = splitVC.viewControllers[0] as UINavigationController
//        let detailNavC = splitVC.viewControllers[1] as UINavigationController
        
        let mainVC = mainNavC.topViewController as MasterViewController
        
        // NOTE: use dispatch_after to check `splitVC.collapsed` after delegation is complete (for iPad)
        // FIXME: look for better solution
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1_000_000), dispatch_get_main_queue()) {
            if !splitVC.collapsed {
                mainVC.showDetailViewControllerAtIndex(0)
            }
        }
        
        return true
    }
    
    func splitViewController(splitViewController: UISplitViewController, collapseSecondaryViewController secondaryViewController:UIViewController!, ontoPrimaryViewController primaryViewController:UIViewController!) -> Bool
    {
        return true
    }
}

