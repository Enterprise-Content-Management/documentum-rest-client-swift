//
//  Type.swift
//  RestClient
//
//  Created by Song, Michyo on 10/19/16.
//  Copyright © 2016 EMC Corporation. All rights reserved.
//

import Foundation

class Type: RestObject {
    var typeProperties: [TypeProperty] = []
    var parentUrl: String!
    var category: String!
    
    override init(entryDic: NSDictionary) {
        super.init(entryDic: entryDic)
        
        let contentDic = entryDic["content"] as! NSDictionary
        category = contentDic["category"] as! String
        parentUrl = contentDic["parent"] as! String
        
        let propertiesArray = contentDic[ObjectProperties.PROPERTIES.rawValue] as! NSArray
        for property in propertiesArray {
            let propertyDic = property as! NSDictionary
            let typeProperty = TypeProperty.init(dic: propertyDic)
            typeProperties.append(typeProperty)
        }
    }
}

struct TypeProperty {
    var name: String
    var repeating: Bool
    var type: String
    var length: Int
    
    init(dic: NSDictionary) {
        name = dic["name"] as! String
        repeating = dic["repeating"] as! Bool
        type = dic["type"] as! String
        length = dic["length"] as! Int
    }
}