//
//  ButtonViewController.swift
//  ReactKitCatalog
//
//  Created by Yasuhiro Inami on 2014/10/06.
//  Copyright (c) 2014年 Yasuhiro Inami. All rights reserved.
//

import UIKit
import ReactKit

class ButtonViewController: UIViewController
{
    @IBOutlet var label: UILabel!
    @IBOutlet var button: UIButton!
    @IBOutlet var barButtonItem: UIBarButtonItem!
    
    var buttonStream: Stream<String?>?
    var barButtonStream: Stream<String?>?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self._setupButton()
        self._setupBarButtonItem()
    }
    
    func _setupButton()
    {
//        self.buttonStream = self.button?.buttonStream("OK")
        self.buttonStream = self.button?.buttonStream { _ in "Button \(arc4random_uniform(UInt32.max))" }
        
        // REACT: button ~> label
        (self.label, "text") <~ self.buttonStream!
        
        // REACT: button ~> println
        ^{ println($0!) } <~ self.buttonStream!
    }
    
    func _setupBarButtonItem()
    {
//        self.barButtonStream = self.barButtonItem?.stream("OK")
        self.barButtonStream = self.barButtonItem?.stream { _ in "BarButton \(arc4random_uniform(UInt32.max))" }
        
        // REACT: button ~> label
        (self.label, "text") <~ self.barButtonStream!
        
        // REACT: button ~> println
        ^{ println($0!) } <~ self.barButtonStream!
    }
}