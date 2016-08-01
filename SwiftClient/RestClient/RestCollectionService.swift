//
//  RestCollectionService.swift
//  RestClient
//
//  Created by Song, Michyo on 4/1/16.
//  Copyright © 2016 EMC Corporation. All rights reserved.
//

import UIKit

class RestCollectionService {
    
    // Properties for dramatical load data
    let itemsPerPage = 20
    
    // Must be defined in subClass
    var url: String!
    
    func setUrl(url: String) {
        self.url = url
    }
    
    internal func getParams(pageNo: NSInteger) -> [String: String] {
        var params = RestUriBuilder.pageParam(itemsPerPage, pageNo: pageNo)
        let inlineParam = RestUriBuilder.inlineParam()
        for param in inlineParam {
            params[param.0] = param.1
        }
        return params
    }
    
    func getService(pageNo: NSInteger, completionHandler: (NSArray?, Error?) -> ()) {
        RestService.getResponseWithParams(self.url!, params: self.getParams(pageNo), completionHandler: completionHandler)
    }
    
    // TODO: Add error control when get error
    func getEntries(
        pageNo: NSInteger,
        thisViewController: UIViewController,
        completionHandler: ([RestObject], Bool) -> ()) {
        self.getService(pageNo) { entries, error in
            if let error = error {
                let errorMsg = error.message
                ErrorAlert.show(errorMsg, controller: thisViewController)
                return
            } else {
                var restObjects = [RestObject]()
                var isLastPage = true
                if let entries = entries {
                    for entry in entries {
                        let dic = entry as! Dictionary<String, AnyObject>
                        let restObject = self.constructRestObject(dic)
                        restObjects.append(restObject)
                    }
                    isLastPage = entries.count < self.itemsPerPage
                }
                completionHandler(restObjects, isLastPage)
            }
        }
    }
    
    // Should be overwrite to construct different kind of rest objects
    func constructRestObject(dic: Dictionary<String, AnyObject>) -> RestObject {
        let restObject = RestObject(
            id: dic["id"] as! String,
            name: dic["title"]! as! String)
        
        let content = dic["content"] as! Dictionary<String, AnyObject>
        let links = content["links"] as! NSArray
        restObject.constructLinks(links)
        
        return restObject
    }
}
