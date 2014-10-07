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
    
    var signal: Signal<NSString?>?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
//        self.signal = self.button?.buttonSignal("OK")
        self.signal = self.button?.buttonSignal { _ in "\(arc4random_uniform(UInt32.max))" }
        
        // REACT: button ~> label
        (self.label, "text") <~ self.signal!
        
        // REACT: button ~> println
        ^{ println($0!) } <~ self.signal!
    }
}