//
//  SysObjectCollectionService.swift
//  RestClient
//
//  Created by Song, Michyo on 4/1/16.
//  Copyright © 2016 EMC Corporation. All rights reserved.
//

import UIKit

class SysObjectCollectionService : RestCollectionService {
    
    var parentObject: RestObject!
    
    init(parentObject: RestObject, url: String) {
        super.init()
        self.parentObject = parentObject
        self.url = url
    }
    
    // Add following params: ?filter=is_private=0 or owner_name='Administrator'
    private func getCabinetsParam(pageNo: NSInteger) -> [String: String] {
        var params = getParams(pageNo)
        params["filter"] = "is_private=0 or owner_name='\(RestUriBuilder.getCurrentUserName())'"
        return params
    }
    
    // Add following params: ?filter=type(dm_document) or type(dm_folder)
    private func getObjectsParam(pageNo: NSInteger) -> [String: String] {
        var params = getParams(pageNo)
        params["filter"] = "type(dm_document) or type(dm_folder)"
        return params
    }
    
    override func getService(pageNo: NSInteger, completionHandler: (NSArray?, Error?) -> ()) {
        super.getService(pageNo, completionHandler: completionHandler)
        
        let params: [String: String]!
        if parentObject.getType() == RestObjectType.repository.rawValue {
            params = getCabinetsParam(pageNo)
        } else {
            params = getObjectsParam(pageNo)
        }
        RestService.getResponseWithAuthAndParam(self.url!, params: params, completionHandler: completionHandler)
    }
    
    func deleteService(url: String, completionHandler: (String?, Error?) -> ()) {
        RestService.deleteWithAuth(url, completionHandler: completionHandler)
    }
    
    override func constructRestObject(dic: Dictionary<String, AnyObject>) -> RestObject {
        let sysObject = super.constructRestObject(dic)
        sysObject.setTypeWithDmType(self.getTypeFromContent(dic))
        return sysObject
    }
    
    private func getTypeFromContent(dic: Dictionary<String, AnyObject>) -> String {
        return getProperty(dic, propertyName: "r_object_type")
    }
    
}
