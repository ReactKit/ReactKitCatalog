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
    
    required init(coder aDecoder: NSCoder)
    {
        self.viewModel = ArrayKVOViewModel()
        
        super.init(coder: aDecoder)
    }
    
    deinit
    {
//        println("[deinit] \(self)")
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self._setupViews()
        self._setupSignals()
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
    
    func _setupSignals()
    {
        // REACT: insert button
        let insertButtonSignal = self.insertButtonItem.signal().ownedBy(self)
        insertButtonSignal ~> { [unowned self] _ in
            println()
            println("[insert button]")
            
            self.viewModel.insertRandomSectionsOrRows()
        }
        
        // REACT: replace button
        let replaceButtonSignal = self.replaceButtonItem.signal().ownedBy(self)
        replaceButtonSignal ~> { [unowned self] _ in
            println()
            println("[replace button]")
            
            self.viewModel.replaceRandomSectionsOrRows()
        }
        
        // REACT: remove button
        let removeButtonSignal = self.removeButtonItem.signal().ownedBy(self)
        removeButtonSignal ~> { [unowned self] _ in
            println()
            println("[remove button]")
            
            self.viewModel.removeRandomSectionsOrRows()
        }
    
        // REACT: decrement button
        let decrementButtonSignal = self.decrementButtonItem.signal().ownedBy(self)
        decrementButtonSignal ~> { [unowned self] _ in
            println()
            println("[decrement button]")
            
            self.viewModel.changeMaxCount = max(self.viewModel.changeMaxCount-1, 1)
        }
        
        // REACT: increment button
        let incrementButtonSignal = self.incrementButtonItem.signal().ownedBy(self)
        incrementButtonSignal ~> { [unowned self] _ in
            println()
            println("[increment button]")
            
            self.viewModel.changeMaxCount = min(self.viewModel.changeMaxCount+1, Int.max)
        }
        
        // REACT: section/row toggle button
        let toggleButtonSignal = self.toggleButtonItem.signal().ownedBy(self)
        toggleButtonSignal ~> { [unowned self] _ in
            println()
            println("[toggle button]")
            
            self.viewModel.tableLocation.toggle()
        }
        
        // REACT: changeMaxCount label
        let changeMaxCountSignal: Signal<AnyObject?> =
            Signal<AnyObject?>.combineLatest([KVO.startingSignal(self.viewModel, "changeMaxCount"), KVO.startingSignal(self.viewModel, "tableLocationString")])
                .map { values -> AnyObject? in "\(values[0]!) \(values[1]!)" }  // e.g. "1 Section"
                .ownedBy(self)
        (self.toggleButtonItem, "title") <~ changeMaxCountSignal
        
        // REACT: sections changed
        self.viewModel.sectionDatas.signal ~> { [unowned self] sectionDatas, sectionChange, sectionIndexSet in
            
            println()
            println("[sectionDatas changed]")
            println("sectionChange = \(sectionChange)")
            println("sectionDatas = \(sectionDatas ?? [])")
            println("sectionIndexSet = \(sectionIndexSet)")
            
            if sectionChange == .Insertion || sectionChange == .Replacement {
                
                sectionIndexSet.enumerateIndexesUsingBlock { sectionIndex, stop in
                    
                    let sectionData = self.viewModel.sectionDatas.proxy[sectionIndex] as SectionData
                
                    // REACT: rows changed
                    sectionData.rowDatas.signal ~> { [weak sectionData] rowDatas, rowChange, rowIndexSet in
                        
                        let sectionData: SectionData! = sectionData // strongify
                        if sectionData == nil { return }
                        
                        println()
                        println("[rowDatas changed]")
                        println("rowChange = \(rowChange)")
                        println("rowDatas = \(rowDatas ?? [])")
                        println("rowIndexSet = \(rowIndexSet)")
                        
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
            println("*** addObject (section & row) ***")
            
            self.viewModel.sectionDatas.proxy.addObject(SectionData(title: "Section 1", rowDatas: [
                RowData(title: "title 1-0"),
                RowData(title: "title 1-1")
            ]))
        }
        
        Async.main(after: 0.2 + step * 1) {
            println("*** insertObject ***")
            
            self.viewModel.sectionDatas.proxy.insertObject(SectionData(title: "Section 0", rowDatas: [
                RowData(title: "title 0-0")
            ]), atIndex: 0)
        }
        
        Async.main(after: 0.2 + step * 2) {
            println("*** replaceObjectAtIndex ***")
            
            self.viewModel.sectionDatas.proxy.replaceObjectAtIndex(0, withObject: SectionData(title: "Section 0b", rowDatas: [
                RowData(title: "title 0-1b")
            ]))
        }
        
        Async.main(after: 0.2 + step * 3) {
            println("*** removeObjectAtIndex ***")
            
            self.viewModel.sectionDatas.proxy.removeObjectAtIndex(0)
        }
        
        Async.main(after: 0.2 + step * 4) {
            println("*** addObject (row) ***")
            
            let sectionData = self.viewModel.sectionDatas.proxy[0] as SectionData
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
        let sectionData = self.viewModel.sectionDatas.proxy[section] as SectionData
        return sectionData.rowDatas.proxy.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier(CELL_IDENTIFIER, forIndexPath: indexPath) as UITableViewCell
        
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
            
            let sectionData = self.viewModel.sectionDatas.proxy[indexPath.section] as SectionData
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
