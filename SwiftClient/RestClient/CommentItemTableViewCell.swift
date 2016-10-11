//
//  CommentItemTableViewCell.swift
//  RestClient
//
//  Created by Song, Michyo on 9/30/16.
//  Copyright © 2016 EMC Corporation. All rights reserved.
//

import UIKit

class CommentItemTableViewCell: UITableViewCell {
    static let height: CGFloat = 135
    
    @IBOutlet weak var authorNameLabel: UILabel!
    @IBOutlet weak var commentDateLabel: UILabel!
    @IBOutlet weak var commentContentLabel: TopAlignTextLabel!
    @IBOutlet weak var replyIconLabel: UILabel!
    @IBOutlet weak var replyButton: UIButton!
    @IBOutlet weak var deleteIconLabel: UILabel!
    @IBOutlet weak var deleteButton: UIButton!
    
    func initCell(comment: Comment) {
        initCell(
            comment.getAuthorName(),
            date: comment.getCommentDate(),
            content: comment.getCommentContent(),
            canDelete: comment.getCanDelete(),
            canReply: comment.getCanReply()
        )
    }
    
    func initCell(name: String, date: String, content: String, canDelete: Bool = true, canReply: Bool = true) {
        authorNameLabel.text = name
        commentDateLabel.text = Utility.getReadableDate(date)!
        commentContentLabel.text = content
        initIcons(canDelete, canReply: canReply)
    }
    
    private func initIcons(canDelete: Bool, canReply: Bool) {
        if !canDelete {
            deleteIconLabel.hidden = true
            deleteButton.hidden = true
        } else {
            IconHelper.setIconForLabel(deleteIconLabel, iconName: .Remove, size: 20)
        }
        
        if !canReply {
            replyIconLabel.hidden = true
            replyButton.hidden = true
        } else {
            IconHelper.setIconForLabel(replyIconLabel, iconName: .Reply, size: 18)
        }
    }
}
