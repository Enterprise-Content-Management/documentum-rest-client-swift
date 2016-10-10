//
//  JsonUtility.swift
//  RestClient
//
//  Created by Song, Michyo on 5/24/16.
//  Copyright © 2016 EMC Corporation. All rights reserved.
//

import SwiftyJSON

class JsonUtility {
    
    static let REQUEST_ROOT = [
        RestObjectType.cabinet.rawValue : "cabinet",
        RestObjectType.folder.rawValue: "folder",
        RestObjectType.user.rawValue: "user",
        RestObjectType.group.rawValue: "group"
        ]
    static let ATTR_NAME = [
        "name": "object_name"
    ]
    
    static func getUpdateRequestBody(type: String, attrDic: Dictionary<String, String>) -> Dictionary<String, AnyObject> {
        let root: String
        if REQUEST_ROOT[type] != nil {
            root = REQUEST_ROOT[type]!
        } else {
            root = "object"
        }
        let dic = ["name": root, "type": type, "properties": attrDic]
        return dic as! Dictionary<String, AnyObject>
    }
    
    static func getUpdateRequestBodySingleAttr(type: String, attrName: String, attrValue: String) -> Dictionary<String, AnyObject> {
        let name: String
        if ATTR_NAME[attrName] != nil {
            name = ATTR_NAME[attrName]!
        } else {
            name = attrName
        }
        let dic = [name: attrValue]
        return self.getUpdateRequestBody(type, attrDic: dic)
    }
    
    static private func getUploadRequestBody(attrDic: Dictionary<String, String>) -> Dictionary<String, AnyObject> {
        var dic: Dictionary<String, AnyObject> = [:]
        dic["properties"] = attrDic
        return dic
    }
    
    static func getUploadRequestBodyJson(attrDic: Dictionary<String, String>) -> JSON {
        let dic = self.getUploadRequestBody(attrDic)
        let json = JSON(dic)
        return json
    }
    
    static func buildBatchRequest(operations: NSArray) -> NSDictionary {
        let batchDic: NSDictionary = [
            "transactional": true,
            "sequential": false,
            "on-error": "CONTINUE",
            "return-request": true,
            "operations": operations
            ]
        
        return batchDic
    }
    
    static func buildSingleBatchOperation(
        id: String, description: String,
        method: String, uri: String,
        headers: NSArray, entity: String) -> NSDictionary {
        let requestDic: NSDictionary = ["method": method, "uri": uri, "headers": headers, "entity": entity]
        let batchOpDic: NSDictionary = ["id": id, "description": description, "request": requestDic]
        return batchOpDic
    }
    
    static func parseDate(dateString: String) -> NSDate? {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'hh:mm:ss.SSSxxx"
        return dateFormatter.dateFromString(dateString)
    }
}
