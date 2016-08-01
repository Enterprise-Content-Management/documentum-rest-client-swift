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
        "dm_cabinet": "cabinet",
        "dm_folder": "folder",
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
}
