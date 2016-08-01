//
//  Repository.swift
//  RestClient
//
//  Created by Song, Michyo on 3/30/16.
//  Copyright © 2016 EMC Corporation. All rights reserved.
//

import UIKit

// Not used.
class Repository : RestObject {
    
    override init(id: String, name: String) {
        super.init(id: id, name: name)
        setType(RestObjectType.repository.rawValue)
    }
}
