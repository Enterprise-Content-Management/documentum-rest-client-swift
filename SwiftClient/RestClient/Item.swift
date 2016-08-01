//
//  Item.swift
//  RestClient
//
//  Created by Song, Michyo on 3/29/16.
//  Copyright © 2016 EMC Corporation. All rights reserved.
//

import UIKit

class Item {
    
    // MARK: Properties
    var url: String
    var itemName: String
    var itemType: String
    var photo: UIImage?
    
    // MARK: Initialization
    init(url: String,  fileType:String, fileName: String, photo: UIImage?) {
        self.url = url
        self.itemName = fileName
        self.itemType = fileType
        self.photo = photo
    }
}
