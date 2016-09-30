//
//  CommentItemTableViewCell.swift
//  RestClient
//
//  Created by Song, Michyo on 9/30/16.
//  Copyright © 2016 EMC Corporation. All rights reserved.
//

import UIKit

class CommentItemTableViewCell: UITableViewCell {
    @IBOutlet weak var authorNameLabel: UILabel!
    @IBOutlet weak var commentDateLabel: UILabel!
    @IBOutlet weak var commentContentLabel: TopAlignTextLabel!
    
    func initCell(comment: Comment) {
        initCell(comment.getAuthorName(), date: comment.getCommentDate(), content: comment.getCommentContent())
    }
    
    func initCell(name: String, date: String, content: String) {
        authorNameLabel.text = name
        commentDateLabel.text = date
        commentContentLabel.text = content
    }
}
