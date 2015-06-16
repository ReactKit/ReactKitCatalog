//
//  IncrementalSearchViewController.swift
//  ReactKitCatalog
//
//  Created by Yasuhiro Inami on 2015/06/01.
//  Copyright (c) 2015年 Yasuhiro Inami. All rights reserved.
//

import UIKit
import ReactKit
import Alamofire
import SwiftyJSON

private func _searchUrl(query: String) -> String
{
    var escapedQuery = query.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet()) ?? ""
    return "http://api.bing.com/osjson.aspx?query=\(escapedQuery)"
}

private let _reuseIdentifier = "reuseIdentifier"

class IncrementalSearchViewController: UITableViewController, UISearchBarDelegate
{
    var searchController: UISearchController?
    var searchResultStream: Stream<JSON>?
    var searchResult: [String]?
    
    dynamic var searchText: String = ""
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        let searchController = UISearchController(searchResultsController: nil)
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.delegate = self
        
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: _reuseIdentifier)
        self.tableView.tableHeaderView = searchController.searchBar
        
        // http://useyourloaf.com/blog/2015/04/26/search-bar-not-showing-without-a-scope-bar.html
        searchController.searchBar.sizeToFit()
        
        self.searchController = searchController
        
        self.searchResultStream = KVO.stream(self, "searchText")
//            |> peek(println)
            |> debounce(0.15)
            |> map { ($0 as? String) ?? "" }    // map to Equatable String for `distinctUntilChanged()`
            |> distinctUntilChanged
            |> map { query -> Stream<JSON> in
                let request = Alamofire.request(.GET, _searchUrl(query), parameters: nil, encoding: .URL)
                return Stream<JSON>.fromTask(_requestTask(request))
            }
            |> switchLatestInner
    
        // REACT
        self.searchResultStream! ~> println
        
        // REACT
        self.searchResultStream! ~> { [weak self] json in
            self?.searchResult = json[1].arrayValue.map { $0.stringValue }
            self?.tableView.reloadData()
        }
    }
    
    // MARK: - UISearchBarDelegate
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String)
    {
        self.searchText = searchText
    }
    
    // MARK: - UITableViewDataSource
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.searchResult?.count ?? 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier(_reuseIdentifier, forIndexPath: indexPath) as! UITableViewCell
        
        cell.textLabel?.text = self.searchResult?[indexPath.row]
        
        return cell
    }
    
}
