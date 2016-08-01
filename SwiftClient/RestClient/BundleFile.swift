//
//  BundleFile.swift
//  RestClient
//
//  Created by Song, Michyo on 6/6/16.
//  Copyright © 2016 EMC Corporation. All rights reserved.
//

import UIKit

class BundleFile {
    var fileName: String
    var filePath: String
    var fileType: String
    
    init(name: String, path: String, type: String) {
        self.fileName = name
        self.filePath = path
        self.fileType = type
    }
}
