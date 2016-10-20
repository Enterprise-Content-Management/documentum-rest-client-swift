//
//  ItemTableViewCell.swift
//  RestClient
//
//  Created by Song, Michyo on 3/29/16.
//  Copyright © 2016 EMC Corporation. All rights reserved.
//

import UIKit

class ItemTableViewCell: UITableViewCell {
    
    // MARK: Properties
    
    @IBOutlet weak var fileNameLabel: UILabel!
    @IBOutlet weak var thumbnailPhotoImageView: UIImageView!
    
    private func initCell(filename: String, fileType: String) {
        fileNameLabel.text = filename
        if let image = UIImage(named: fileType) {
            thumbnailPhotoImageView.image = image
        } else {
            thumbnailPhotoImageView.image = UIImage(named: "SysObject")
        }
    }
    
    func getInfoButton() -> UIButton {
        let buttons = contentView.subviews.filter{ view in
            return view is UIButton
        }
        return buttons[0] as! UIButton
    }
    
    func initCell(object: RestObject) {
        initCell(object.getName(), fileType: object.getType())
        
        let infoButton = getInfoButton()
        
        if object.getType() == RestObjectType.repository.rawValue
            || object.getLink(LinkRel.objects) != nil {
            accessoryType = .DisclosureIndicator
            infoButton.hidden = false
        } else {
            accessoryType = .None
            infoButton.hidden = true
        }
    }
    
    func canGoDeep() {
        accessoryType = .DisclosureIndicator
        getInfoButton().hidden = false
    }
    
    func canNotGoDeep() {
        accessoryType = .None
        getInfoButton().hidden = true
    }
}
