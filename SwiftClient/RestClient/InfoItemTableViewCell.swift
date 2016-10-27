//
//  InfoItemTableViewCell.swift
//  RestClient
//
//  Created by Song, Michyo on 5/23/16.
//  Copyright © 2016 EMC Corporation. All rights reserved.
//

import UIKit

class InfoItemTableViewCell : UITableViewCell {
    
    @IBOutlet weak var infoNameLabel: UILabel!
    @IBOutlet weak var infoValueLabel: UITextView!
    
    func initCell(name: String, value: String, style: InfoItemCellStyle = .Basic) {
        infoNameLabel.text = name
        infoValueLabel.text = value
        
        infoNameLabel.lineBreakMode = .ByWordWrapping
        
        switch style {
        case .Basic:
            setBasicStyle()
        case .Infomation:
            setInfomationStyle()
        case .Link:
            setLinkStyle()
        case .ProductInfo:
            setProductInfoStyle()
        }
    }
    
    func setBasicStyle() {
        infoNameLabel.font = UIFont.boldSystemFontOfSize(16)
        infoValueLabel.font = infoValueLabel.font?.fontWithSize(14)
    }

    func setInfomationStyle() {
        infoNameLabel.font = UIFont.boldSystemFontOfSize(14)
        infoValueLabel.font = infoValueLabel.font?.fontWithSize(14)
    }
    
    func setLinkStyle() {
        infoNameLabel.font = infoNameLabel.font.fontWithSize(14)
        infoValueLabel.font = infoValueLabel.font?.fontWithSize(12)
    }
    
    func setProductInfoStyle() {
        infoNameLabel.font = UIFont.boldSystemFontOfSize(15)
        infoValueLabel.font = infoValueLabel.font?.fontWithSize(17)
    }
    
    enum InfoItemCellStyle {
        case Basic
        case Infomation
        case Link
        case ProductInfo
    }
}
