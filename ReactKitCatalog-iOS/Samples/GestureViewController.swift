//
//  GestureViewController.swift
//  ReactKitCatalog
//
//  Created by Yasuhiro Inami on 2014/10/06.
//  Copyright (c) 2014年 Yasuhiro Inami. All rights reserved.
//

import UIKit
import ReactKit

class GestureViewController: UIViewController, UIGestureRecognizerDelegate
{
    @IBOutlet var gestures: [UIGestureRecognizer]!
    @IBOutlet var label: UILabel!
    
    var signals: [Signal<NSString?>] = []
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        for gesture in self.gestures {
            
            gesture.delegate = self;
            
            let signal: Signal<NSString?> = gesture.signal { gesture -> NSString? in
                // e.g. UITapGestureRecognizer state=3 (161.0,325.0)
                return "\(NSStringFromClass(gesture!.dynamicType)) state=\(gesture!.state.rawValue) \(gesture!.locationInView(gesture?.view))"
            }
            
            // REACT: gesture ~> println
            ^{ println($0!) } <~ signal
            
            self.signals += [signal]
            
        }
        
        // combinedSignal (concatenating above signal-strings)
        let combinedSignal = Signal.merge2(self.signals).map { (values: [NSString??], changedValue: NSString?) -> NSString? in
            
            //
            // WARNING: 2014/12/16
            //
            // When release-build, this closure is getting called on MultipleTextFieldViewController's textField input for some reason,
            // even though this GestureViewController's `viewDidLoad` has never been called.
            // It seems `Signal.merge2()` has been treated as sort of singleton object (shared among other viewControllers) on release-build,
            // which is definitely a Swift compiler's bug because this never happens on debug-build.
            //
            
            return "\n".join(values.map { ($0 ?? "")!! as String }.filter { !$0.isEmpty })
        }
        
        // REACT: anySignal ~> label
        (self.label, "text") <~ combinedSignal
        
        self.signals += [combinedSignal]
        
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool
    {
        return true
    }
}