//
//  Group.swift
//  RestClient
//
//  Created by Song, Michyo on 8/26/16.
//  Copyright © 2016 EMC Corporation. All rights reserved.
//

import UIKit

class Group: RestObject {
    var owner: String
    
    override init(id: String, name: String) {
        owner = ""
        super.init(id: id, name: name)
    }
    
    convenience init(id: String, name: String, owner: String) {
        self.init(id: id, name: name)
        self.owner = owner
    }
    
    func getOwner() -> String {
        return owner
    }
}
