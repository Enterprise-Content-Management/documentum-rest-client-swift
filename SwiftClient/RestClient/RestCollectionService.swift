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
    
    private func getLatestUrl() {
        if (url != nil) {
            let rootUrl = DbUtil.getValueFromTable(attrName: DbUtil.ATTR_ROOTURL)
            let root = rootUrl?.characters.split("/").map(String.init)
            let context = DbUtil.getValueFromTable(attrName: DbUtil.ATTR_CONTEXT)
            var strings = url.characters.split("/").map(String.init)
            strings[0] += "/"
            strings[1] = root![1]
            strings[2] = (context! as NSString).substringFromIndex(1)
            url = strings.joinWithSeparator("/")
        }
    }
    
    func getService(pageNo: NSInteger, completionHandler: (NSArray?, Error?) -> ()) {
        getLatestUrl()
    }
    
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
    
    internal func getContent(dic: Dictionary<String, AnyObject>, contentName: String) -> AnyObject {
        let content = dic["content"] as! Dictionary<String, AnyObject>
        return content[contentName]!
    }
    
    internal func getProperty(dic: Dictionary<String, AnyObject>, propertyName: String) -> String {
        let properties = getContent(dic, contentName: "properties")
        let property = properties[propertyName] as! String
        return property
    }
}
