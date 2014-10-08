//
//  BarButtonItemViewController.swift
//  ReactKitCatalog
//
//  Created by Yasuhiro Inami on 2014/10/08.
//  Copyright (c) 2014年 Yasuhiro Inami. All rights reserved.
//

import UIKit
import ReactKit

class BarButtonItemViewController: UIViewController
{
    @IBOutlet var label: UILabel!
    @IBOutlet var barButtonItem: UIBarButtonItem!
    
    var signal: Signal<NSString?>?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
//        self.signal = self.barButtonItem?.signal("OK")
        self.signal = self.barButtonItem?.signal { _ in "\(arc4random_uniform(UInt32.max))" }
        
        // REACT: button ~> label
        (self.label, "text") <~ self.signal!
        
        // REACT: button ~> println
        ^{ println($0!) } <~ self.signal!
    }
}
