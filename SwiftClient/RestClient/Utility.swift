//
//  Utility.swift
//  RestClient
//
//  Created by Song, Michyo on 10/10/16.
//  Copyright © 2016 EMC Corporation. All rights reserved.
//

import UIKit

class Utility {
    
    static func getReadableDate(date: NSDate) -> String {
        let formatter = NSDateFormatter()
        formatter.dateStyle = NSDateFormatterStyle.LongStyle
        formatter.timeStyle = .MediumStyle

        return formatter.stringFromDate(date)
    }
    
    static func getReadableDate(jsonDate: String) -> String? {
        let result = JsonUtility.parseDate(jsonDate)
        if let date = result {
            return getReadableDate(date)
        } else {
            return nil
        }
    }
}
