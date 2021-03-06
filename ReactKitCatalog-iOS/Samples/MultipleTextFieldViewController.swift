//
//  MultipleTextFieldViewController.swift
//  ReactKitCatalog
//
//  Created by Yasuhiro Inami on 2014/10/06.
//  Copyright (c) 2014年 Yasuhiro Inami. All rights reserved.
//

import UIKit
import ReactKit

private let MIN_PASSWORD_LENGTH = 4

///
/// Original demo:
/// iOS - ReactiveCocoaをかじってみた - Qiita
/// http://qiita.com/paming/items/9ac189ab0fe5b25fe722
///
class MultipleTextFieldViewController: UIViewController
{
    @IBOutlet var usernameTextField: UITextField!
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var password2TextField: UITextField!
    
    @IBOutlet var messageLabel: UILabel!
    @IBOutlet var okButton: UIButton!
    
    var buttonEnablingStream: Stream<NSNumber?>?
    var buttonEnablingStream2: Stream<[AnyObject?]>?
    var errorMessagingStream: Stream<String?>?
    var buttonTappedStream: Stream<String?>?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self._setupViews()
        self._setupStreams()
    }
    
    func _setupViews()
    {
        self.messageLabel.text = ""
        self.okButton.enabled = false
    }
    
    func _setupStreams()
    {
        //--------------------------------------------------
        // Create Streams
        //--------------------------------------------------
        
        let usernameTextStream = self.usernameTextField.textChangedStream()
        let emailTextStream = self.emailTextField.textChangedStream()
        let passwordTextStream = self.passwordTextField.textChangedStream()
        let password2TextStream = self.password2TextField.textChangedStream()
        
        let combinedTextStream = [usernameTextStream, emailTextStream, passwordTextStream, password2TextStream]
            |> merge2All
        
        // create button-enabling stream via any textField change
        self.buttonEnablingStream = combinedTextStream
            |> map { (values, changedValue) -> NSNumber? in
                
                let username = (values[0] ?? nil) ?? ""
                let email = (values[1] ?? nil) ?? ""
                let password = (values[2] ?? nil) ?? ""
                let password2 = (values[3] ?? nil) ?? ""
                
                print("username=\(username), email=\(email), password=\(password), password2=\(password2)")
                
                // validation
                let buttonEnabled = username.characters.count > 0 && email.characters.count > 0 && password.characters.count >= MIN_PASSWORD_LENGTH && password == password2
                
                print("buttonEnabled = \(buttonEnabled)")
                
                return NSNumber(bool: buttonEnabled)    // NOTE: use NSNumber because KVO does not understand Bool
            }
        
        // create error-messaging stream via any textField change
        self.errorMessagingStream = combinedTextStream
            |> map { (values, changedValue) -> String? in
            
                let username = (values[0] ?? nil) ?? ""
                let email = (values[1] ?? nil) ?? ""
                let password = (values[2] ?? nil) ?? ""
                let password2 = (values[3] ?? nil) ?? ""
                
                if username.characters.count <= 0 {
                    return "Username is not set."
                }
                else if email.characters.count <= 0 {
                    return "Email is not set."
                }
                else if password.characters.count < MIN_PASSWORD_LENGTH {
                    return "Password requires at least \(MIN_PASSWORD_LENGTH) characters."
                }
                else if password != password2 {
                    return "Password is not same."
                }
                
                return nil
            }
        
        // create button-tapped stream via okButton
        self.buttonTappedStream = self.okButton.buttonStream("OK")
        
        //--------------------------------------------------
        // Stream callbacks on finished
        //--------------------------------------------------
        
        self.buttonEnablingStream?.then { value, errorInfo -> Void in
            print("buttonEnablingStream finished")
        }
        self.errorMessagingStream?.then { value, errorInfo -> Void in
            print("errorMessagingStream finished")
        }
        self.buttonTappedStream?.then { value, errorInfo -> Void in
            print("buttonTappedStream finished")
        }
        
        //--------------------------------------------------
        // Bind & React to Streams
        //--------------------------------------------------
        
        // REACT: enable/disable okButton
        (self.okButton, "enabled") <~ self.buttonEnablingStream!
        
        // REACT: update error-message
        (self.messageLabel, "text") <~ self.errorMessagingStream!
        
        // REACT: button tap
        self.buttonTappedStream! ~> { [weak self] (value: String?) -> Void in
            if let self_ = self {
                if value == "OK" {
                    // release all streams when receiving "OK" stream
                    self_.buttonEnablingStream = nil
                    self_.errorMessagingStream = nil
                    self_.buttonTappedStream = nil
                }
            }
        }
    }
}
