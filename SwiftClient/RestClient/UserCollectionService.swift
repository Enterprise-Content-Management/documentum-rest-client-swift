//
//  UserCollectionService.swift
//  RestClient
//
//  Created by Song, Michyo on 9/5/16.
//  Copyright © 2016 EMC Corporation. All rights reserved.
//

import UIKit

class UserCollectionService: RestCollectionService {
    
    override func getService(pageNo: NSInteger, completionHandler: (NSArray?, Error?) -> ()) {
        super.getService(pageNo, completionHandler: completionHandler)
        RestService.getResponseWithAuthAndParam(self.url!, params: self.getParams(pageNo), completionHandler: completionHandler)
    }
    
    override func constructRestObject(dic: Dictionary<String, AnyObject>) -> RestObject {
        let restObject: RestObject
        let contentDic = dic["content"] as! Dictionary<String, AnyObject>
        restObject = User(dic: contentDic)
        return restObject
    }

}
