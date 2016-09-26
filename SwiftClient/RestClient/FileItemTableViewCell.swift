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
        fileNameLabel.text = path
    }
}
