//
//  WhoToFollowViewController.swift
//  ReactKitCatalog
//
//  Created by Yasuhiro Inami on 2015/01/05.
//  Copyright (c) 2015年 Yasuhiro Inami. All rights reserved.
//

import UIKit
import ReactKit
import SwiftTask

import Alamofire
import SwiftyJSON
import Haneke

///
/// Original demo:
///
/// - The introduction to Reactive Programming you've been missing"
///   https://gist.github.com/staltz/868e7e9bc2a7b8c1f754)
///
/// - "Who to follow" Demo (JavaScript)
///   http://jsfiddle.net/staltz/8jFJH/48/
///
class WhoToFollowViewController: UIViewController {

    @IBOutlet var user1Button: UIButton!
    @IBOutlet var user2Button: UIButton!
    @IBOutlet var user3Button: UIButton!
    @IBOutlet var refreshButton: UIButton!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self._setupButtons()
    }
    
    func _setupButtons()
    {
        let refreshButtonSignal: Signal<NSString?> = self.refreshButton!.buttonSignal("refresh")
        
        let user1ButtonSignal = self.user1Button!.buttonSignal(1)
        let user2ButtonSignal = self.user2Button!.buttonSignal(2)
        let user3ButtonSignal = self.user3Button!.buttonSignal(3)
        
        /// refreshButton -> random URL -> get JSON
        let jsonSignal = refreshButtonSignal
            .startWith("refresh on start")
            .map { _ -> Alamofire.Request in
                let since = Int(arc4random_uniform(500))
                return Alamofire.request(.GET, "https://api.github.com/users", parameters: ["since" : since], encoding: .URL)
            }
            .flatMap { [weak self] in Signal<SwiftyJSON.JSON>.fromTask(self!._requestTask($0)) }
        
        typealias UserDict = [String : AnyObject]
        
        func createRandomUserSignal(userButtonSignal: Signal<Int>) -> Signal<UserDict?>
        {
            // `Signal.merge2()` a.k.a `Rx.combineLatest()`
            // NOTE: use `asSignal(Any)` whenever combining with different Signal types
            return Signal<Any>.merge2([userButtonSignal.asSignal(Any).startWith("clear"), jsonSignal.asSignal(Any)])
                .map { values, changedValue -> UserDict? in
                    
                    if let json = values.last as? SwiftyJSON.JSON {
                        let randomIndex = Int(arc4random_uniform(UInt32(json.count)))
                        return json[randomIndex].dictionaryObject ?? nil
                    }
                    else {
                        return nil
                    }
                }
                .merge(refreshButtonSignal.map { _ in nil })
            
        }
        let randomUser1Signal = createRandomUserSignal(user1ButtonSignal)
        let randomUser2Signal = createRandomUserSignal(user2ButtonSignal)
        let randomUser3Signal = createRandomUserSignal(user3ButtonSignal)
        
        // OWNED: retain signals by `self` (convenient method in replace of `self.retainingSignals += [mySignal]`)
        randomUser1Signal.ownedBy(self)
        randomUser2Signal.ownedBy(self)
        randomUser3Signal.ownedBy(self)
        
        //--------------------------------------------------
        // Render
        //--------------------------------------------------
        
        func renderUserButton(userButton: UIButton?, userDict: UserDict?)
        {
            userButton?.setTitle(userDict?["login"] as? String, forState: .Normal)
            userButton?.setImage(nil, forState: .Normal)
            
            // resize & update avatar using HanekeSwift
            if let avatarURLString = userDict?["avatar_url"] as? String {
                let avatarURL = NSURL(string: avatarURLString)
                if let avatarURL = avatarURL {
                    userButton?.hnk_setImageFromURL(avatarURL, state: .Normal, placeholder: nil, format: nil, failure: nil, success: nil)
                }
            }
            
        }
        
        // REACT: userButton ~> re-render
        randomUser1Signal ~> { [weak self] userDict in
            renderUserButton(self?.user1Button, userDict)
        }
        randomUser2Signal ~> { [weak self] userDict in
            renderUserButton(self?.user2Button, userDict)
        }
        randomUser3Signal ~> { [weak self] userDict in
            renderUserButton(self?.user3Button, userDict)
        }
        
    }
    
    /// analogous to JavaScript's `$.getJSON(requestUrl)` using Alamofire & SwiftyJSON
    func _requestTask(request: Alamofire.Request) -> Task<Void, SwiftyJSON.JSON, NSError>
    {
        return Task<Void, SwiftyJSON.JSON, NSError> { fulfill, reject in
            
            println("request to GitHub")

            request.responseJSON { request, response, jsonObject, error in
                
                println("response (JSON) from Github")
                
                if let error = error {
                    reject(error)
                    return
                }
                
                Async.background {
                    let json = JSON(jsonObject!)
                    
                    Async.main {
                        fulfill(json)
                    }
                }
                
            }
            return
        }
    }
    
}
