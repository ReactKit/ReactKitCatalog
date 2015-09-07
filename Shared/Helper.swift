//
//  Helper.swift
//  ReactKitCatalog
//
//  Created by Yasuhiro Inami on 2015/03/21.
//  Copyright (c) 2015年 Yasuhiro Inami. All rights reserved.
//

import Foundation
import Dollar
import SwiftTask
import Alamofire
import SwiftyJSON
import Async

// pick `count` random elements from `sequence`
func _pickRandom<S: SequenceType>(sequence: S, _ count: Int) -> [S.Generator.Element]
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

enum CatalogError: String, ErrorType
{
    case InvalidArgument
}

/// analogous to JavaScript's `$.getJSON(requestUrl)` using Alamofire & SwiftyJSON
func _requestTask(request: Alamofire.Request) -> Task<Void, SwiftyJSON.JSON, ErrorType>
{
    guard let urlString = request.request?.URLString else {
        return Task(error: CatalogError.InvalidArgument)
    }
    
    return Task { fulfill, reject in
        
        print("request to \(urlString)")
        
        request.responseJSON { request, response, result in
            
            print("response from \(urlString)")
            
            if let error = result.error {
                reject(error)
                return
            }
            
            Async.background {
                let json = JSON(result.value!)
                
                Async.main {
                    fulfill(json)
                }
            }
            
        }
        return
    }
}