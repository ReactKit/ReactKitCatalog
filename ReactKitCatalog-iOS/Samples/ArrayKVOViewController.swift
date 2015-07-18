//
//  ArrayKVOViewController.swift
//  ReactKitCatalog
//
//  Created by Yasuhiro Inami on 2015/03/21.
//  Copyright (c) 2015年 Yasuhiro Inami. All rights reserved.
//

import UIKit
import ReactKit
import Dollar

let CELL_IDENTIFIER = "Cell"

class ArrayKVOViewController: UITableViewController
{
    typealias SectionData = ArrayKVOViewModel.SectionData
    typealias RowData = ArrayKVOViewModel.RowData
    
    let viewModel: ArrayKVOViewModel
    
    let insertButtonItem = UIBarButtonItem(title: "Insert", style: .Plain, target: nil, action: nil)
    let replaceButtonItem = UIBarButtonItem(title: "Replace", style: .Plain, target: nil, action: nil)
    let removeButtonItem = UIBarButtonItem(title: "Remove", style: .Plain, target: nil, action: nil)
    let decrementButtonItem = UIBarButtonItem(title: "[-]", style: .Plain, target: nil, action: nil)
    let toggleButtonItem = UIBarButtonItem(title: nil, style: .Plain, target: nil, action: nil)
    let incrementButtonItem = UIBarButtonItem(title: "[+]", style: .Plain, target: nil, action: nil)
    let flexibleButtonItem = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?)
    {
        self.viewModel = ArrayKVOViewModel()
        
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        self.viewModel = ArrayKVOViewModel()
        
        super.init(coder: aDecoder)
    }
    
    deinit
    {
//        print("[deinit] \(self)")
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self._setupViews()
        self._setupStreams()
        self._performDemo()
    }
    
    func _setupViews()
    {
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: CELL_IDENTIFIER)
        self.tableView.editing = true
        
        self.toolbarItems = [
            self.flexibleButtonItem,
            self.insertButtonItem, self.replaceButtonItem, self.removeButtonItem,
            self.flexibleButtonItem,
            self.decrementButtonItem, self.toggleButtonItem, self.incrementButtonItem,
            self.flexibleButtonItem
        ]
        self.navigationController?.setToolbarHidden(false, animated: false)
    }
    
    func _setupStreams()
    {
        // REACT: insert button
        let insertButtonStream = self.insertButtonItem.stream().ownedBy(self)
        insertButtonStream ~> { [unowned self] _ in
            print()
            print("[insert button]")
            
            self.viewModel.insertRandomSectionsOrRows()
        }
        
        // REACT: replace button
        let replaceButtonStream = self.replaceButtonItem.stream().ownedBy(self)
        replaceButtonStream ~> { [unowned self] _ in
            print()
            print("[replace button]")
            
            self.viewModel.replaceRandomSectionsOrRows()
        }
        
        // REACT: remove button
        let removeButtonStream = self.removeButtonItem.stream().ownedBy(self)
        removeButtonStream ~> { [unowned self] _ in
            print()
            print("[remove button]")
            
            self.viewModel.removeRandomSectionsOrRows()
        }
    
        // REACT: decrement button
        let decrementButtonStream = self.decrementButtonItem.stream().ownedBy(self)
        decrementButtonStream ~> { [unowned self] _ in
            print()
            print("[decrement button]")
            
            self.viewModel.changeMaxCount = max(self.viewModel.changeMaxCount-1, 1)
        }
        
        // REACT: increment button
        let incrementButtonStream = self.incrementButtonItem.stream().ownedBy(self)
        incrementButtonStream ~> { [unowned self] _ in
            print()
            print("[increment button]")
            
            self.viewModel.changeMaxCount = min(self.viewModel.changeMaxCount+1, Int.max)
        }
        
        // REACT: section/row toggle button
        let toggleButtonStream = self.toggleButtonItem.stream().ownedBy(self)
        toggleButtonStream ~> { [unowned self] _ in
            print()
            print("[toggle button]")
            
            self.viewModel.tableLocation.toggle()
        }
        
        // REACT: changeMaxCount label
        let changeMaxCountStream: Stream<AnyObject?> = [
            KVO.startingStream(self.viewModel, "changeMaxCount"),
            KVO.startingStream(self.viewModel, "tableLocationString")
        ]
            |> combineLatestAll
            |> map { values -> AnyObject? in "\(values[0]!) \(values[1]!)" }  // e.g. "1 Section"
        
        changeMaxCountStream.ownedBy(self)
        (self.toggleButtonItem, "title") <~ changeMaxCountStream
        
        // REACT: sections changed
        let sectionDatasChangedStream = self.viewModel.sectionDatas.stream().ownedBy(self.viewModel)
        sectionDatasChangedStream ~> { [unowned self] sectionDatas, sectionChange, sectionIndexSet in
            
            print()
            print("[sectionDatas changed]")
            print("sectionChange = \(sectionChange)")
            print("sectionDatas = \(sectionDatas ?? [])")
            print("sectionIndexSet = \(sectionIndexSet)")
            
            if sectionChange == .Insertion || sectionChange == .Replacement {
                
                sectionIndexSet.enumerateIndexesUsingBlock { sectionIndex, stop in
                    
                    let sectionData = self.viewModel.sectionDatas.proxy[sectionIndex] as! SectionData
                
                    // REACT: rows changed
                    let rowDatasChangedStream = sectionData.rowDatas.stream().ownedBy(sectionData)
                    rowDatasChangedStream ~> { [weak sectionData] rowDatas, rowChange, rowIndexSet in
                        
                        let sectionData: SectionData! = sectionData // strongify
                        if sectionData == nil { return }
                        
                        print()
                        print("[rowDatas changed]")
                        print("rowChange = \(rowChange)")
                        print("rowDatas = \(rowDatas ?? [])")
                        print("rowIndexSet = \(rowIndexSet)")
                        
                        // NOTE: sectionIndex needs to be re-evaluated on rows changed
                        let sectionIndex = self.viewModel.sectionDatas.proxy.indexOfObject(sectionData)
                        
                        var indexPaths: [NSIndexPath] = []
                        rowIndexSet.enumerateIndexesUsingBlock { rowIndex, stop in
                            indexPaths.append(NSIndexPath(forRow: rowIndex, inSection: sectionIndex))
                        }
                        
                        self.tableView.beginUpdates()
                        
                        switch rowChange {
                            case .Insertion:
                                self.tableView.insertRowsAtIndexPaths(indexPaths, withRowAnimation: .Right)
                            case .Replacement:
                                self.tableView.reloadRowsAtIndexPaths(indexPaths, withRowAnimation: .Right)
                            case .Removal:
                                self.tableView.deleteRowsAtIndexPaths(indexPaths, withRowAnimation: .Left)
                            default:
                                break
                        }
                        
                        self.tableView.endUpdates()
                    }
                }
            }
            
            self.tableView.beginUpdates()
            
            switch sectionChange {
                case .Insertion:
                    self.tableView.insertSections(sectionIndexSet, withRowAnimation: .Right)
                case .Replacement:
                    self.tableView.reloadSections(sectionIndexSet, withRowAnimation: .Right)
                case .Removal:
                    self.tableView.deleteSections(sectionIndexSet, withRowAnimation: .Left)
                default:
                    break
            }
            
            self.tableView.endUpdates()
        }
        
    }
    
    func _performDemo()
    {
        self.tableView.userInteractionEnabled = false
        
        let step = 0.5 // sec
        
        Async.main(after: 0.2 + step * 0) {
            print("*** addObject (section & row) ***")
            
            self.viewModel.sectionDatas.proxy.addObject(SectionData(title: "Section 1", rowDataArray: [
                RowData(title: "title 1-0"),
                RowData(title: "title 1-1")
            ]))
        }
        
        Async.main(after: 0.2 + step * 1) {
            print("*** insertObject ***")
            
            self.viewModel.sectionDatas.proxy.insertObject(SectionData(title: "Section 0", rowDataArray: [
                RowData(title: "title 0-0")
            ]), atIndex: 0)
        }
        
        Async.main(after: 0.2 + step * 2) {
            print("*** replaceObjectAtIndex ***")
            
            self.viewModel.sectionDatas.proxy.replaceObjectAtIndex(0, withObject: SectionData(title: "Section 0b", rowDataArray: [
                RowData(title: "title 0-1b")
            ]))
        }
        
        Async.main(after: 0.2 + step * 3) {
            print("*** removeObjectAtIndex ***")
            
            self.viewModel.sectionDatas.proxy.removeObjectAtIndex(0)
        }
        
        Async.main(after: 0.2 + step * 4) {
            print("*** addObject (row) ***")
            
            let sectionData = self.viewModel.sectionDatas.proxy[0] as! SectionData
            sectionData.rowDatas.proxy.addObject(RowData(title: "title 1-2"))
            
            self.tableView.userInteractionEnabled = true
        }
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return self.viewModel.sectionDatas.proxy.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        let sectionData = self.viewModel.sectionDatas.proxy[section] as! SectionData
        return sectionData.rowDatas.proxy.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier(CELL_IDENTIFIER, forIndexPath: indexPath)
        
        cell.textLabel?.text = self.viewModel.sectionDatas.proxy[indexPath.section][indexPath.row].title

        return cell
    }

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool
    {
        // Return NO if you do not want the specified item to be editable.
        return true
    }

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath)
    {
        if editingStyle == .Delete {
            
            let sectionData = self.viewModel.sectionDatas.proxy[indexPath.section] as! SectionData
            sectionData.rowDatas.proxy.removeObjectAtIndex(indexPath.row)
            
        } else if editingStyle == .Insert {
            
        }    
    }

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        return self.viewModel.sectionDatas.proxy[section].title
    }

    // MARK: UITableViewDelegate
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        return 30
    }
    
}
