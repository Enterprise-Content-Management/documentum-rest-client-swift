//
//  CommentFootView.swift
//  RestClient
//
//  Created by Song, Michyo on 10/10/16.
//  Copyright © 2016 EMC Corporation. All rights reserved.
//

import UIKit

class CommentFootView: UITableViewCell {
    static let height: CGFloat = 35
    
    @IBOutlet weak var newCommentImageLabel: UILabel!
    @IBOutlet weak var newCommentButton: UIButton!
    
    func initCell() {
        IconHelper.setIconForLabel(newCommentImageLabel, iconName: .CommentO, size: 18)
        contentView.backgroundColor = UIColor.whiteColor()
    }
}
