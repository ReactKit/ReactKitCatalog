//
//  MasterViewController.swift
//  ReactKitCatalog-iOS
//
//  Created by Yasuhiro Inami on 2014/10/06.
//  Copyright (c) 2014年 Yasuhiro Inami. All rights reserved.
//

import UIKit
import Dollar

class MasterViewController: UITableViewController
{
    let catalogs = Catalog.allCatalogs()
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            self.clearsSelectionOnViewWillAppear = false
            self.preferredContentSize = CGSize(width: 320.0, height: 600.0)
        }
    }

    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // auto-select
        if let index = $.findIndex(self.catalogs, { $0.selected }) {
            self.showDetailViewControllerAtIndex(index)
        }
    }
    
    //--------------------------------------------------
    // MARK: - UITableViewDataSource
    //--------------------------------------------------
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.catalogs.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell

        let catalog = self.catalogs[indexPath.row]
        cell.textLabel?.text = catalog.title
        cell.detailTextLabel?.text = catalog.description
        
        return cell
    }
    
    // MARK: UITableViewDelegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        self.showDetailViewControllerAtIndex(indexPath.row)
    }
    
    func showDetailViewControllerAtIndex(index: Int)
    {
        let catalog = self.catalogs[index]
        
        //
        // change Swift's className to Obj-C nibName
        //
        // e.g. 
        // NSStringFromClass(catalog.class_)
        // = "ReactKitCatalog_iOS.TextFieldViewController"
        //
        let className = NSStringFromClass(catalog.class_).componentsSeparatedByString(".").last
        
        if let className = className {
            
            let newVC = catalog.class_(nibName: className, bundle: nil)
            let newNavC = UINavigationController(rootViewController: newVC)
            self.splitViewController?.showDetailViewController(newNavC, sender: self)
            
            newVC.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
            newVC.navigationItem.leftItemsSupplementBackButton = true
            
        }
    }

}

