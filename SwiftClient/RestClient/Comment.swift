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
        let authorDic = (entryDic["author"] as! NSArray)[0] as! Dictionary<String, String>
        author = Author(name: authorDic["name"], uri: authorDic["uri"])
        commentContent = entryDic["summary"] as! String
    }
    
    override init(singleDic: NSDictionary) {
        super.init(singleDic: singleDic)
        
        // TODO: need modify
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
    var uri: String!
}
