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
    @IBOutlet var throttleLabel: UILabel!
    @IBOutlet var debounceLabel: UILabel!
    @IBOutlet var textField: UITextField!
    
    var signal: Signal<NSString?>?
    var throttleSignal: Signal<NSString?>?
    var debounceSignal: Signal<NSString?>?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.signal = self.textField?.textChangedSignal()
        self.throttleSignal = self.signal?.throttle(1).map { text -> NSString? in "\(text!) (throttled)" }
        self.debounceSignal = self.signal?.debounce(1).map { text -> NSString? in "\(text!) (debounced)" }
        
        // REACT: textField ~> label
        (self.label, "text") <~ self.signal!
        
        // REACT: textField ~> throttleLabel
        (self.throttleLabel, "text") <~ self.throttleSignal!
        
        // REACT: textField ~> debounceLabel
        (self.debounceLabel, "text") <~ self.debounceSignal!
        
//        // REACT: textField ~> println
//        ^{ println($0!) } <~ self.signal!
    }
}