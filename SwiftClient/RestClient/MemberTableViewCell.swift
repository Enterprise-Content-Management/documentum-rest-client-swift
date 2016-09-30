//
//  MemberTableViewCell.swift
//  RestClient
//
//  Created by Song, Michyo on 9/21/16.
//  Copyright © 2016 EMC Corporation. All rights reserved.
//

import UIKit

class MemberTableViewCell: UITableViewCell {
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    func initCell(photoName: String, name: String) {
        setThumbnailImage(photoName)
        setName(name)
    }
    
    func initCell(object: RestObject) {
        initCell(object.getType(), name: object.getName())
    }
    
    func setThumbnailImage(photoName: String) {
        iconImageView.image = UIImage(named: photoName)
    }
    
    func setName(name: String) {
        nameLabel.text = name
    }
}
