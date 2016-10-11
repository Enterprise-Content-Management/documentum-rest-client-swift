//
//  Comment.swift
//  RestClient
//
//  Created by Song, Michyo on 9/30/16.
//  Copyright © 2016 EMC Corporation. All rights reserved.
//

import UIKit

class Comment: RestObject {
    private var author: Author!
    private var commentContent: String!
    private var canDelete: Bool!
    private var canReply: Bool!
    
    override init(entryDic: NSDictionary) {
        super.init(entryDic: entryDic)
        
        let authorDic = (entryDic["author"] as! NSArray)[0] as! Dictionary<String, String>
        author = Author(name: authorDic["name"], uri: authorDic["uri"])
        
        let singleDic = entryDic["content"] as! NSDictionary
        setSingleComment(singleDic)
    }
    
    override init(singleDic: NSDictionary) {
        super.init(singleDic: singleDic)
        
        author = Author(name: singleDic["owner-name"] as! String, uri: nil)
        setSingleComment(singleDic)
    }
    
    private func setSingleComment(dic: NSDictionary) {
        commentContent = dic["content-value"] as! String
        canDelete = dic["can-delete"] as! Bool
        canReply = dic["can-reply"] as! Bool
        
        setUpdated(dic["modified-date"] as! String)
        setPublished(dic["creation-date"] as! String)
        
        let parentId = dic["parent-id"] as! String
        if parentId == "0" {
            setType(RestObjectType.comment.rawValue)
        } else {
            setType(RestObjectType.reply.rawValue)
        }
    }
    
    func getAuthorName() -> String {
        return author.name
    }
    
    func getCommentDate() -> String {
        return getUpdated()
    }
    
    func getCommentContent() -> String {
        return commentContent
    }
    
    func getCanDelete() -> Bool {
        return canDelete
    }
    
    func getCanReply() -> Bool {
        return canReply
    }
}

struct Author {
    var name: String!
    var uri: String?
}
