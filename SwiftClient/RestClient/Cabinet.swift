//
//  Cabinet.swift
//  RestClient
//
//  Created by Song, Michyo on 3/31/16.
//  Copyright © 2016 EMC Corporation. All rights reserved.
//

import UIKit

class Cabinet : RestObject {
    override init(id: String, name: String) {
        super.init(id: id, name: name)
        setType(RestObjectType.cabinet.rawValue)
    }
}
