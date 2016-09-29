//
//  IconHelper.swift
//  RestClient
//
//  Created by Song, Michyo on 9/27/16.
//  Copyright © 2016 EMC Corporation. All rights reserved.
//

import UIKit
import FontAwesome_swift

class IconHelper {

    static func setIconForButton(button: UIButton, iconName: FontAwesome, size: CGFloat = 25, state: UIControlState = .Normal) {
        button.titleLabel?.font = UIFont.fontAwesomeOfSize(size)
        button.setTitle(String.fontAwesomeIconWithName(iconName), forState: state)
    }
    
    static func setIconForBarButton(button: UIBarButtonItem, iconName: FontAwesome, size: CGFloat = 22, state: UIControlState = .Normal) {
        let attributes = [NSFontAttributeName: UIFont.fontAwesomeOfSize(size)] as Dictionary!
        button.setTitleTextAttributes(attributes, forState: state)
        button.title = String.fontAwesomeIconWithName(iconName)
    }
    
    static func setIconForLabel(label: UILabel, iconName: FontAwesome, size: CGFloat = 25) {
        label.font = UIFont.fontAwesomeOfSize(size)
        label.text = String.fontAwesomeIconWithName(iconName)
    }
    
    static func setIconForImage(
        imageView: UIImageView, iconName: FontAwesome,
        width: CGFloat = 25,
        height: CGFloat = 25,
        textColor: UIColor = UIColor.grayColor(),
        backgroundColor: UIColor = UIColor.clearColor()) {
        imageView.image = UIImage.fontAwesomeIconWithName(iconName, textColor: textColor, size: CGSizeMake(width, height), backgroundColor: backgroundColor)
    }
}
