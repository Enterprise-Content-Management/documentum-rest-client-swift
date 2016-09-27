//
//  Group.swift
//  RestClient
//
//  Created by Song, Michyo on 8/26/16.
//  Copyright © 2016 EMC Corporation. All rights reserved.
//

import UIKit

class Group: RestObject {
    var owner: String!
    
    override init(singleDic: NSDictionary) {
        super.init(singleDic: singleDic)
        owner = getProperty(.OWNER_NAME) as! String
    }
    
    override init(entryDic: NSDictionary) {
        super.init(entryDic: entryDic)
        owner = getProperty(.OWNER_NAME) as! String
    }
    
    func getOwner() -> String {
        return owner
    }
}
