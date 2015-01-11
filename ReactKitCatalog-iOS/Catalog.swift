//
//  Catalog.swift
//  ReactKitCatalog
//
//  Created by Yasuhiro Inami on 2014/10/06.
//  Copyright (c) 2014年 Yasuhiro Inami. All rights reserved.
//

import UIKit

struct Catalog
{
    let title: String?
    let description: String?
    let class_: UIViewController.Type
    let selected: Bool
    
    static func allCatalogs() -> [Catalog]
    {
        return [
            Catalog(title: "NSTimer", description: "pause()/resume()", class_: TimerViewController.self),
            Catalog(title: "UIButton/BarButton", description: "Basic", class_: ButtonViewController.self),
            Catalog(title: "UITextField", description: "throttle()/debounce()", class_: TextFieldViewController.self),
            Catalog(title: "UITextField (Multiple)", description: "Login example", class_: MultipleTextFieldViewController.self),
            Catalog(title: "UIGestureRecognizer", description: "Signal.merge2()", class_: GestureViewController.self),
            Catalog(title: "Who To Follow", description: "Suggestion box", class_: WhoToFollowViewController.self, selected: true)
        ]
    }
    
    init(title: String?, description: String?, class_: UIViewController.Type, selected: Bool = false)
    {
        self.title = title
        self.description = description
        self.class_ = class_
        self.selected = selected
    }
}