//
//  Error.swift
//  RestClient
//
//  Created by Song, Michyo on 7/5/16.
//  Copyright © 2016 EMC Corporation. All rights reserved.
//

import UIKit
import SwiftyJSON

class Error {
    var status: NSInteger!
    var errorCode: String!
    var message: String! 
    var details: String!
    var id: String!
    
    init(msg: String, detail: String = "nothing") {
        status = 0
        errorCode = "E_ERROR"
        if msg == "" {
            message = "Lost connection. Please check if REST server is running."
        } else {
            message = msg
        }
        details = detail
        id = "ID"
    }
    
    init(json: JSON) {
        status = json["status"].intValue
        errorCode = json["code"].stringValue
        message = json["message"].stringValue
        if message == "" {
            message = "Lost connection. Please check if REST server is running."
        }
        details = json["details"].stringValue
        id = json["id"].stringValue
    }
}
