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
    
    static func allCatalogs() -> [Catalog]
    {
        return [
            Catalog(title: "NSTimer", description: nil, class_: TimerViewController.self),
            Catalog(title: "UIBarButtonItem", description: nil, class_: BarButtonItemViewController.self),
            Catalog(title: "UIButton", description: nil, class_: ButtonViewController.self),
            Catalog(title: "UITextField", description: nil, class_: TextFieldViewController.self),
            Catalog(title: "UITextField (Multiple)", description: nil, class_: MultipleTextFieldViewController.self),
            Catalog(title: "UIGestureRecognizer", description: nil, class_: GestureViewController.self)
        ]
    }
}