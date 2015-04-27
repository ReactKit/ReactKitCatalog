//
//  TimerViewController.swift
//  ReactKitCatalog
//
//  Created by Yasuhiro Inami on 2014/10/06.
//  Copyright (c) 2014年 Yasuhiro Inami. All rights reserved.
//

import UIKit
import ReactKit

class TimerViewController: UIViewController
{
    @IBOutlet var label: UILabel!
    @IBOutlet var pauseResumeButton: UIButton!
    @IBOutlet var cancelButton: UIButton!
    
    var stream: Stream<NSString?>?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // NOTE: use class method (no need to create NSTimer-instance)
        self.stream = NSTimer.stream(timeInterval: 1) { (sender: NSTimer?) -> NSString? in
            return "\(NSDate())"
        }
        
        // REACT: button ~> label
        (self.label, "text") <~ self.stream!
        
        // REACT: button ~> println
        ^{ println($0!) } <~ self.stream!
    }
    
    override func viewDidDisappear(animated: Bool)
    {
        super.viewDidDisappear(animated)
        
        switch self.stream!.state {
            case .Cancelled:
                break
            default:
                println()
                println("NOTE: TimerViewController is not deinited yet (due to iOS8-UISplitViewController's behavior) so timer-stream is still alive.")
                println()
        }
    }
    
    // use IBAction instead of ReactKit.Stream for this tutorial
    @IBAction func handlePauseResumeButton(sender: AnyObject)
    {
        let button = sender as! UIButton
        
        switch self.stream!.state {
            case .Paused:
                self.stream?.resume()
                button.setTitle("Pause", forState: .Normal)
            case .Running:
                self.stream?.pause()
                button.setTitle("Resume", forState: .Normal)
            default:
                println("Do nothing (timer-stream is already cancelled)")
                break
        }
        
    }
    
    @IBAction func handleCancelButton(sender: AnyObject)
    {
        self.stream?.cancel()
    }
}