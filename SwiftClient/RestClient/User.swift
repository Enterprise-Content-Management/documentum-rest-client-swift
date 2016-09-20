//
//  User.swift
//  RestClient
//
//  Created by Song, Michyo on 6/30/16.
//  Copyright © 2016 EMC Corporation. All rights reserved.
//

import UIKit

class User: RestObject {
    
    var properties: Dictionary<String, String> = [:]
    
    override init(dic: NSDictionary) {
        super.init(dic: dic)
        let props = dic["properties"] as! NSDictionary
        for property in props {
            let key = property.key as! String
            var value = property.value
            if value is NSInteger {
                value = String(value)
            }
            self.properties[key] = value as? String
        }
        setType(RestObjectType.user.rawValue)
    }
    
    override func getName() -> String {
        return properties["user_name"]!
    }
    
    func getProperty(propertyName: String) -> String? {
        return properties[propertyName]
    }
}
