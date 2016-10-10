//
//  Comment.swift
//  RestClient
//
//  Created by Song, Michyo on 9/30/16.
//  Copyright © 2016 EMC Corporation. All rights reserved.
//

import UIKit

class Comment: RestObject {
    var author: Author!
    var commentContent: String!
    
    override init(entryDic: NSDictionary) {
        super.init(entryDic: entryDic)
        
        setType(RestObjectType.comment.rawValue)
        let singleDic = entryDic["content"] as! NSDictionary
        commentContent = singleDic["content-value"] as! String
        
        let authorDic = (entryDic["author"] as! NSArray)[0] as! Dictionary<String, String>
        author = Author(name: authorDic["name"], uri: authorDic["uri"])
    }
    
    override init(singleDic: NSDictionary) {
        super.init(singleDic: singleDic)

        setType(RestObjectType.comment.rawValue)
        setUpdated(singleDic["modified-date"] as! String)
        setPublished(singleDic["creation-date"] as! String)
        
        author = Author(name: singleDic["owner-name"] as! String, uri: nil)
        commentContent = singleDic["content-value"] as! String
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
}

struct Author {
    var name: String!
    var uri: String?
}
