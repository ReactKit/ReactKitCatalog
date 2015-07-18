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
        let refreshButtonStream: Stream<String?> = self.refreshButton!.buttonStream("refresh")
        
        let user1ButtonStream = self.user1Button!.buttonStream(1)
        let user2ButtonStream = self.user2Button!.buttonStream(2)
        let user3ButtonStream = self.user3Button!.buttonStream(3)
        
        /// refreshButton -> random URL -> get JSON
        let jsonStream = refreshButtonStream
            |> startWith("refresh on start")
            |> map { _ -> Alamofire.Request in
                let since = Int(arc4random_uniform(500))
                return Alamofire.request(.GET, URLString: "https://api.github.com/users", parameters: ["since" : since], encoding: .URL)
            }
            |> flatMap { Stream<SwiftyJSON.JSON>.fromTask(_requestTask($0)) }
        
        typealias UserDict = [String : AnyObject]
        
        func createRandomUserStream(userButtonStream: Stream<Int>) -> Stream<UserDict?>
        {
            let streams: [Stream<Any>] = [
                userButtonStream
                    |> map { $0 as Any }
                    |> startWith("clear"),
                jsonStream
                    |> map { $0 as Any }
            ]
            return streams |> combineLatestAll
                |> map { values -> UserDict? in
                    
                    if let json = values.last as? SwiftyJSON.JSON {
                        let randomIndex = Int(arc4random_uniform(UInt32(json.count)))
                        return json[randomIndex].dictionaryObject ?? nil
                    }
                    else {
                        return nil
                    }
                }
                |> merge(refreshButtonStream |> map { _ in nil })
            
        }
        let randomUser1Stream = createRandomUserStream(user1ButtonStream)
        let randomUser2Stream = createRandomUserStream(user2ButtonStream)
        let randomUser3Stream = createRandomUserStream(user3ButtonStream)
        
        // OWNED: retain streams by `self` (convenient method in replace of `self.retainingStreams += [myStream]`)
        randomUser1Stream.ownedBy(self)
        randomUser2Stream.ownedBy(self)
        randomUser3Stream.ownedBy(self)
        
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
        randomUser1Stream ~> { [weak self] userDict in
            renderUserButton(self?.user1Button, userDict: userDict)
        }
        randomUser2Stream ~> { [weak self] userDict in
            renderUserButton(self?.user2Button, userDict: userDict)
        }
        randomUser3Stream ~> { [weak self] userDict in
            renderUserButton(self?.user3Button, userDict: userDict)
        }
        
    }
    
    
}
