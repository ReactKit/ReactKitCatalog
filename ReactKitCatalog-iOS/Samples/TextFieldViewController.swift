//
//  TextFieldViewController.swift
//  ReactKitCatalog
//
//  Created by Yasuhiro Inami on 2014/10/06.
//  Copyright (c) 2014年 Yasuhiro Inami. All rights reserved.
//

import UIKit
import ReactKit

class TextFieldViewController: UIViewController
{
    @IBOutlet var label: UILabel!
    @IBOutlet var textField: UITextField!
    
    var signal: Signal<NSString?>?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.signal = self.textField?.textChangedSignal()
        
        // REACT: textField ~> label
        (self.label, "text") <~ self.signal!
        
        // REACT: textField ~> println
        ^{ println($0!) } <~ self.signal!
    }
}