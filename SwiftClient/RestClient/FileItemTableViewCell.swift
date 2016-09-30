//
//  FileItemTableViewCell.swift
//  RestClient
//
//  Created by Song, Michyo on 6/6/16.
//  Copyright © 2016 EMC Corporation. All rights reserved.
//

import UIKit

class FileItemTableViewCell: UITableViewCell {
    @IBOutlet weak var fileNameLabel: UILabel!
    @IBOutlet weak var filePathLabel: UILabel!
    
    func initCell(name: String, path: String) {
        fileNameLabel.text = name
        filePathLabel.text = path
    }
    
    func initCell(file: BundleFile) {
        fileNameLabel.text = file.fileName
        filePathLabel.text = file.filePath
    }
}
