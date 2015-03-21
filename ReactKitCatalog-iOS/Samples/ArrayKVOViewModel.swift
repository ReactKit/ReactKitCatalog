//
//  ArrayKVOViewModel.swift
//  ReactKitCatalog
//
//  Created by Yasuhiro Inami on 2015/03/21.
//  Copyright (c) 2015年 Yasuhiro Inami. All rights reserved.
//

import Foundation
import ReactKit
import Dollar

let defaultTableLocation = ArrayKVOViewModel.TableLocation.Section

class ArrayKVOViewModel: NSObject
{
    var sectionDatas = DynamicArray/*<SectionData>*/()
    
    /// used as insert/replace/remove maxCount
    dynamic var changeMaxCount = 1
    
    // workaround for KVO-signaling Swift enum
    private(set) dynamic var tableLocationString = defaultTableLocation.rawValue
    
    // NOTE: `dynamic var` is not available
    var tableLocation: TableLocation = defaultTableLocation
    {
        didSet(oldValue) {
            self.tableLocationString = self.tableLocation.rawValue
        }
    }
}

/// helper methods
extension ArrayKVOViewModel
{
    func insertRandomSectionsOrRows()
    {
        switch self.tableLocation {
            case .Section:
                self._insertRandomSections()
            
            case .Row:
                self._insertRandomRows()
        }
    }
    
    private func _insertRandomSections()
    {
        precondition(self.changeMaxCount > 0)
        
        let sectionCount = self.sectionDatas.proxy.count
        
        let indexes = _pickRandom(0...sectionCount, self.changeMaxCount)
        let indexSet = NSMutableIndexSet(indexes: indexes)
        
        let sectionDatas = [Int](count: indexSet.count, repeatedValue: 0)
            .map { _ in SectionData.randomData() }
        
        // insert sections
        self.sectionDatas.proxy.insertObjects(sectionDatas, atIndexes: indexSet)
    }
    
    private func _insertRandomRows()
    {
        precondition(self.changeMaxCount > 0)
        
        let sectionCount = self.sectionDatas.proxy.count
        
        // insert section if needed
        if sectionCount == 0 {
            self.sectionDatas.proxy.addObject(SectionData.emptyData())
        }
        
        let section = $.random(sectionCount)
        let sectionData = self.sectionDatas.proxy[section] as SectionData
        let rowCount = sectionData.rowDatas.proxy.count
        
        let indexes = _pickRandom(0...rowCount, self.changeMaxCount)
        let indexSet = NSMutableIndexSet(indexes: indexes)
        
        let rowDatas = [Int](count: indexSet.count, repeatedValue: 0).map { _ in RowData.randomData() }
        
        // insert rows
        sectionData.rowDatas.proxy.insertObjects(rowDatas, atIndexes: indexSet)
    }
    
    func replaceRandomSectionsOrRows()
    {
        switch self.tableLocation {
            case .Section:
                self._replaceRandomSections()
                
            case .Row:
                self._replaceRandomRows()
        }
    }
    
    private func _replaceRandomSections()
    {
        precondition(self.changeMaxCount > 0)
        
        let sectionCount = self.sectionDatas.proxy.count
        
        let indexes = _pickRandom(0..<sectionCount, min(self.changeMaxCount, sectionCount))
        let indexSet = NSMutableIndexSet(indexes: indexes)
        
        let sectionDatas = [Int](count: indexSet.count, repeatedValue: 0).map { _ in SectionData.randomData() }
        
        // replace sections
        self.sectionDatas.proxy.replaceObjectsAtIndexes(indexSet, withObjects: sectionDatas)
    }
    
    private func _replaceRandomRows()
    {
        precondition(self.changeMaxCount > 0)
        
        let sectionCount = self.sectionDatas.proxy.count
        
        let section = $.random(sectionCount)
        let sectionData = self.sectionDatas.proxy[section] as SectionData
        let rowCount = sectionData.rowDatas.proxy.count
        
        let indexes = _pickRandom(0..<rowCount, min(self.changeMaxCount, rowCount))
        let indexSet = NSMutableIndexSet(indexes: indexes)
        
        let rowDatas = [Int](count: indexSet.count, repeatedValue: 0).map { _ in RowData.randomData() }
        
        // replace rows
        sectionData.rowDatas.proxy.replaceObjectsAtIndexes(indexSet, withObjects: rowDatas)
    }
    
    func removeRandomSectionsOrRows()
    {
        switch self.tableLocation {
            case .Section:
                self._removeRandomSections()
                
            case .Row:
                self._removeRandomRows()
        }
    }
    
    private func _removeRandomSections()
    {
        precondition(self.changeMaxCount > 0)
        
        let sectionCount = self.sectionDatas.proxy.count
        
        let indexes = _pickRandom(0..<sectionCount, min(self.changeMaxCount, sectionCount))
        let indexSet = NSMutableIndexSet(indexes: indexes)
        
        // remove sections
        self.sectionDatas.proxy.removeObjectsAtIndexes(indexSet)
    }
    
    private func _removeRandomRows()
    {
        precondition(self.changeMaxCount > 0)
        
        let sectionCount = self.sectionDatas.proxy.count
        
        let section = $.random(sectionCount)
        let sectionData = self.sectionDatas.proxy[section] as SectionData
        let rowCount = sectionData.rowDatas.proxy.count
        
        let indexes = _pickRandom(0..<rowCount, min(self.changeMaxCount, rowCount))
        let indexSet = NSMutableIndexSet(indexes: indexes)
        
        // remove rows
        sectionData.rowDatas.proxy.removeObjectsAtIndexes(indexSet)
    }
}

// inner class implementation
extension ArrayKVOViewModel
{
    // inner class (NOTE: NSObject-subclassing is required to set inside NSArray)
    class SectionData: NSObject
    {
        let title: String
        let rowDatas: DynamicArray/*<RowData>*/
        
        init(title: String, rowDatas: DynamicArray/*<RowData>*/)
        {
            self.title = title
            self.rowDatas = rowDatas
        }
        
        convenience init(title: String, rowDatas: [RowData])
        {
            self.init(title: title, rowDatas: DynamicArray/*<RowData>*/(rowDatas))
        }
        
        subscript(i: Int) -> RowData
        {
            return self.rowDatas.proxy[i] as RowData
        }
        
        /// return 1 sectionData with random (0..<3) rowDatas
        class func randomData() -> SectionData
        {
            let dateString = _dateString(NSDate())
            
            let rowDatas = Array(0..<$.random(3))
                .map { i -> RowData in
                    return RowData(title: "\(dateString)-\(i)")
            }
            
            return SectionData(title: "\(dateString)", rowDatas: rowDatas)
        }
        
        /// return 1 sectionData with 0 rowDatas
        class func emptyData() -> SectionData
        {
            let dateString = _dateString(NSDate())
            
            return SectionData(title: "\(dateString)", rowDatas: [])
        }
    }
    
    // inner class
    class RowData: NSObject
    {
        let title: String
        
        init(title: String)
        {
            self.title = title
        }
        
        class func randomData() -> RowData
        {
            let dateString = _dateString(NSDate())
            
            return RowData(title: "\(dateString)")
        }
    }
    
    // inner enum
    enum TableLocation: String, Printable
    {
        case Section = "Section"
        case Row = "Row"
        
        var description: String
        {
            return self.rawValue
        }
        
        mutating func toggle()
        {
            switch self {
                case .Section: self = .Row
                case .Row: self = .Section
            }
        }
    }
}