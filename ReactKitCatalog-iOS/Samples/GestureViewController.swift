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
    
    var streams: [Stream<NSString?>] = []
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        for gesture in self.gestures {
            
            gesture.delegate = self
            let gestureClassName = NSStringFromClass(gesture.dynamicType)
            
            let stream: Stream<NSString?> = gesture.stream { gesture -> NSString? in
                // e.g. UITapGestureRecognizer state=3 (161.0,325.0)
                return "\(gestureClassName) state=\(gesture!.state.rawValue) \(gesture!.locationInView(gesture?.view))"
            }
            
            // REACT: gesture ~> println
            ^{ println($0!) } <~ stream
            
            self.streams += [stream]
            
        }
        
        // combinedStream (concatenating above stream-strings)
        let combinedStream = self.streams
            |> merge2All
            |> map { (values: [NSString??], changedValue: NSString?) -> NSString? in
            
            return "\n"
                .join(values.map { ($0 ?? "")!! as String }
                .filter { !$0.isEmpty })
        }
        
        // REACT
        (self.label, "text") <~ combinedStream
        
        self.streams += [combinedStream]
        
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool
    {
        return true
    }
}