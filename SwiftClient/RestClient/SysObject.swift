//
//  SysObject.swift
//  RestClient
//
//  Created by Song, Michyo on 4/1/16.
//  Copyright © 2016 EMC Corporation. All rights reserved.
//

import UIKit

class SysObject: RestObject {
    
    override init(id: String, name: String) {
        super.init(id: id, name: name)
        setType(RestObjectType.sysObject.rawValue)
    }
    
    convenience init(id: String, name: String, type: String) {
        self.init(id: id, name: name)
        self.setType(type)
    }
    
}

