//
//  User.swift
//  RestClient
//
//  Created by Song, Michyo on 6/30/16.
//  Copyright © 2016 EMC Corporation. All rights reserved.
//

import UIKit

class User: RestObject {
    
    override func getName() -> String {
        return properties[ObjectProperties.USER_NAME]! as! String
    }
}
