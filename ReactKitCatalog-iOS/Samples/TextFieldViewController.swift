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
    
    var stream: Stream<String?>?
    var throttleStream: Stream<String?>?
    var debounceStream: Stream<String?>?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.stream = self.textField?.textChangedStream()
        self.throttleStream = self.stream!
            |> throttle(1)
            |> map { text -> String? in "\(text!) (throttled)" }
        self.debounceStream = self.stream!
            |> debounce(1)
            |> map { text -> String? in "\(text!) (debounced)" }
        
        // REACT: textField ~> label
        (self.label, "text") <~ self.stream!
        
        // REACT: textField ~> throttleLabel
        (self.throttleLabel, "text") <~ self.throttleStream!
        
        // REACT: textField ~> debounceLabel
        (self.debounceLabel, "text") <~ self.debounceStream!
        
//        // REACT: textField ~> println
//        ^{ println($0!) } <~ self.stream!
    }
}