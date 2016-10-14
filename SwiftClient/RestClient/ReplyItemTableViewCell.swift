//
//  ReplyItemTableViewCell.swift
//  RestClient
//
//  Created by Song, Michyo on 10/11/16.
//  Copyright © 2016 EMC Corporation. All rights reserved.
//

import UIKit

class ReplyItemTableViewCell: UITableViewCell {
    static let height: CGFloat = 100
    
    @IBOutlet weak var iconLabel: UILabel!
    @IBOutlet weak var autherNameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var contentLabel: TopAlignTextLabel!
    
    func initCell(comment: Comment) {
        IconHelper.setIconForLabel(iconLabel, iconName: .CommentsO, size: 16)
        setComment(comment)
    }
    
    private func setComment(comment: Comment) {
        var prefix = ""
        if let parent = comment.getParentComment() {
            prefix = "@\(parent.getAuthorName()) "
        }
        autherNameLabel.text = comment.getAuthorName()
        dateLabel.text = Utility.getReadableDate(comment.getCommentDate(), dateStyle: .MediumStyle, timeStyle: .ShortStyle)!
        contentLabel.text = prefix + comment.getCommentContent()
    }
}
