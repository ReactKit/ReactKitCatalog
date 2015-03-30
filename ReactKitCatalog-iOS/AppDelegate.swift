//
//  AppDelegate.swift
//  ReactKitCatalog-iOS
//
//  Created by Yasuhiro Inami on 2014/10/06.
//  Copyright (c) 2014年 Yasuhiro Inami. All rights reserved.
//

import UIKit
import Alamofire
import BigBrother

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate {

    var window: UIWindow?
    
    func _setupAppearance()
    {
        let font = UIFont(name: "AvenirNext-Medium", size: 16)!
        
        UINavigationBar.appearance().titleTextAttributes = [ NSFontAttributeName : font ]
        UIBarButtonItem.appearance().setTitleTextAttributes([ NSFontAttributeName : font ], forState: .Normal)
//        UIButton.appearance().titleLabel?.font = font
//        UILabel.appearance().font = font
//        UITextField.appearance().font = font
//        UITextView.appearance().font = font
    }
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool
    {
        // setup BigBrother (networkActivityIndicator)
        BigBrother.addToSharedSession()
        BigBrother.addToSessionConfiguration(Alamofire.Manager.sharedInstance.session.configuration)
        
        self._setupAppearance()
        
        let splitVC = self.window!.rootViewController as! UISplitViewController
        splitVC.delegate = self
        
        let mainNavC = splitVC.viewControllers[0] as! UINavigationController
//        let detailNavC = splitVC.viewControllers[1] as UINavigationController
        
        let mainVC = mainNavC.topViewController as! MasterViewController
        
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

