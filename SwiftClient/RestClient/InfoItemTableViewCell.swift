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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}
