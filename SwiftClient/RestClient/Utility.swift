//
//  Utility.swift
//  RestClient
//
//  Created by Song, Michyo on 10/10/16.
//  Copyright © 2016 EMC Corporation. All rights reserved.
//

import UIKit

class Utility {
    
    static func getReadableDate(
        jsonDate: String,
        dateStyle: NSDateFormatterStyle = .LongStyle,
        timeStyle: NSDateFormatterStyle = .MediumStyle
        ) -> String? {
        let result = JsonUtility.parseDate(jsonDate)
        if let date = result {
            return getReadableDate(date, dateStyle: dateStyle, timeStyle: timeStyle)
        } else {
            return nil
        }
    }
    
    static func getReadableDate(
        date: NSDate,
        dateStyle: NSDateFormatterStyle = .LongStyle,
        timeStyle: NSDateFormatterStyle = .MediumStyle
        ) -> String {
        let formatter = NSDateFormatter()
        formatter.dateStyle = dateStyle
        formatter.timeStyle = timeStyle
        return formatter.stringFromDate(date)
    }
}
