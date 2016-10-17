//
//  DqlResult.swift
//  RestClient
//
//  Created by Song, Michyo on 10/17/16.
//  Copyright © 2016 EMC Corporation. All rights reserved.
//

import UIKit

class DqlResult: RestObject {
    
    override init(searchDic: NSDictionary) {
        super.init(searchDic: searchDic)
        
        setBasic(.ID, value: searchDic[ObjectProperties.ID.rawValue] as! String)
        setBasic(.NAME, value: searchDic["title"]! as! String)
        setUpdated(searchDic[ObjectProperties.UPDATED.rawValue] as! String)
        setPublished(searchDic[ObjectProperties.PUBLISHED.rawValue] as! String)
        
        let content = searchDic["content"] as! Dictionary<String, AnyObject>
        let definition = content["definition"] as! String
        let dmType = definition.characters.split("/").map(String.init).last
        if let dm = dmType {
            setTypeWithDmType(dm)
        }
        properties = content[ObjectProperties.PROPERTIES.rawValue] as! Dictionary<String, AnyObject>
        
        let links = content[ObjectProperties.LINKS.rawValue] as! NSArray
        constructLinks(links)
    }
}
