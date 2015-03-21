//
//  Helper.swift
//  ReactKitCatalog
//
//  Created by Yasuhiro Inami on 2015/03/21.
//  Copyright (c) 2015年 Yasuhiro Inami. All rights reserved.
//

import Foundation
import Dollar

// pick `count` random elements from `sequence`
func _pickRandom<S: SequenceType>(sequence: S, count: Int) -> [S.Generator.Element]
{
    var array = Array(sequence)
    var pickedArray = Array<S.Generator.Element>()
    
    for _ in 0..<count {
        if array.isEmpty { break }
        
        pickedArray.append(array.removeAtIndex($.random(array.count)))
    }
    
    return pickedArray
}

let dateFormatter: NSDateFormatter = {
    let formatter = NSDateFormatter()
    formatter.dateFormat = "yyyy/MM/dd HH:mm:ss.SSS"
    return formatter
}()

func _dateString(date: NSDate) -> String
{
    return dateFormatter.stringFromDate(date)
}