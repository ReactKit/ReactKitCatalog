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
    
    var buttonSignal: Signal<NSString?>?
    var barButtonSignal: Signal<NSString?>?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self._setupButton()
        self._setupBarButtonItem()
    }
    
    func _setupButton()
    {
//        self.buttonSignal = self.button?.buttonSignal("OK")
        self.buttonSignal = self.button?.buttonSignal { _ in "Button \(arc4random_uniform(UInt32.max))" }
        
        // REACT: button ~> label
        (self.label, "text") <~ self.buttonSignal!
        
        // REACT: button ~> println
        ^{ println($0!) } <~ self.buttonSignal!
    }
    
    func _setupBarButtonItem()
    {
//        self.barButtonSignal = self.barButtonItem?.signal("OK")
        self.barButtonSignal = self.barButtonItem?.signal { _ in "BarButton \(arc4random_uniform(UInt32.max))" }
        
        // REACT: button ~> label
        (self.label, "text") <~ self.barButtonSignal!
        
        // REACT: button ~> println
        ^{ println($0!) } <~ self.barButtonSignal!
    }
}