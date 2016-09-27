//
//  CheckBox.swift
//  RestClient
//
//  Created by Song, Michyo on 6/30/16.
//  Copyright © 2016 EMC Corporation. All rights reserved.
//

import UIKit

class CheckBox : UIButton {
    
    // Bool property
    var isChecked: Bool = false {
        didSet {
            if isChecked == true {
                IconHelper.setIconForButton(self, iconName: .CheckSquareO, size: 20)
            } else {
                IconHelper.setIconForButton(self, iconName: .SquareO, size: 20)
            }
        }
    }
    
    override func awakeFromNib() {
        addTarget(self, action: #selector(CheckBox.buttonClicked(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        isChecked = false
    }
    
    func buttonClicked(sender: UIButton) {
        if sender == self {
            isChecked = !isChecked
        }
    }
}