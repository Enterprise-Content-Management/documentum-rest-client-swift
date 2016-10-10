//
//  CommentCollectionService.swift
//  RestClient
//
//  Created by Song, Michyo on 10/9/16.
//  Copyright © 2016 EMC Corporation. All rights reserved.
//

import UIKit

class CommentCollectionService: RestCollectionService {
    
    override func getService(pageNo: NSInteger, completionHandler: (NSArray?, Error?) -> ()) {
        super.getService(pageNo, completionHandler: completionHandler)
        
        RestService.getResponseWithAuthAndParam(url, params: getParams(pageNo), completionHandler: completionHandler)

    }
    
    override func constructRestObject(dic: Dictionary<String, AnyObject>) -> RestObject {
        let restObject = Comment(entryDic: dic)
        return restObject
    }
}
