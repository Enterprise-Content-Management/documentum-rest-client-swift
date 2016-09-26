//
//  GroupCollectionService.swift
//  RestClient
//
//  Created by Song, Michyo on 8/29/16.
//  Copyright © 2016 EMC Corporation. All rights reserved.
//

import UIKit

class GroupCollectionService: RestCollectionService {

    override func getService(pageNo: NSInteger, completionHandler: (NSArray?, Error?) -> ()) {
        super.getService(pageNo, completionHandler: completionHandler)
        RestService.getResponseWithAuthAndParam(self.url!, params: self.getParams(pageNo), completionHandler: completionHandler)
    }
    
    override func constructRestObject(dic: Dictionary<String, AnyObject>) -> RestObject {
        let name = getContent(dic, contentName: "name") as! String
        let restObject: RestObject
        if name == "group" {
            restObject = Group(entryDic: dic)
        } else {
            restObject = User(entryDic: dic)
        }
        setRemoveMemberLink(restObject, dic: dic)
        return restObject
    }
    
    private func setRemoveMemberLink(object: RestObject, dic: Dictionary<String, AnyObject>) {
        let outLinks = dic["links"] as! NSArray
        for link in outLinks {
            if let d = link as? NSDictionary {
                if d["rel"] as! String == LinkRel.delete.rawValue {
                    object.setLink(LinkRel.removeMember.rawValue, href: d["href"]! as! String)
                    break
                }
            }
        }
    }
    
    private func getOwner(dic: Dictionary<String, AnyObject>) -> String {
        return getProperty(dic, propertyName: "owner_name")
    }
}
