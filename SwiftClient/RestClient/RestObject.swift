//
//  RestObject.swift
//  RestClient
//
//  Created by Song, Michyo on 3/31/16.
//  Copyright © 2016 EMC Corporation. All rights reserved.
//

import UIKit

class RestObject {
    
    var basic: Dictionary<String, String> = [
        "id": "",
        "type": "",
        "name": ""
    ]
    var links: Dictionary<String, String> = [:]
    
    init(id: String, name: String) {
        basic["id"] = id
        basic["name"] = name
    }
    
    // Only used in RestService.getRestObject
    init(dic: NSDictionary) {
        let links = dic["links"] as! NSArray
        constructLinks(links)
        let id = getLink("self")
        basic["id"] = id
        let props = dic["properties"] as! NSDictionary
        if let type = props["r_object_type"] as? String {
            basic["type"] = RestObject.getShowType(type)
        }
        basic["name"] = props["object_name"] as? String
    }
    
    func setType(type: String) {
        basic["type"] = RestObject.getShowType(type)
    }
    
    func getName() -> String {
        return basic["name"]!
    }
    
    func getId() -> String {
        return basic["id"]!
    }
    
    func getType() -> String {
        return basic["type"]!
    }
    
    func getNameWithType() -> String {
        return basic["type"]! + " " + basic["name"]!
    }
    
    func setLink(rel: String, href: String) -> Dictionary<String, String> {
        links[rel] = href
        return links
    }
    
    func getLink(rel: String) -> String? {
        return links[rel]
    }
    
    func getRawId() -> String {
        let idArray = getId().characters.split("/").map(String.init)
        let last = idArray.count - 1
        return idArray[last]
    }
    
    func getRawParentID() -> String {
        let parentLink = getLink(LinkRel.parent.rawValue)!
        let idArray = parentLink.characters.split("/").map(String.init)
        let last = idArray.count - 1
        return idArray[last]
    }
    
    static func getRawLinkRel(rel: String) -> String {
        let array = rel.characters.split("/").map(String.init)
        let last = array.count - 1
        return array[last]
    }
    
    
    func constructLinks(linksArray: NSArray) {
        for linkItem in linksArray {
            let linkItemDic = linkItem as! Dictionary<String, String>
            if linkItemDic["href"] != nil {
                self.setLink(linkItemDic["rel"]!, href: linkItemDic["href"]!)
            } else if linkItemDic["hreftemplate"] != nil {
                self.setLink(linkItemDic["rel"]!, href: linkItemDic["hreftemplate"]!)
            }
        }
    }
    
    static func getShowType(type: String) -> String {
        switch type {
            case "Repository": return RestObjectType.repository.rawValue
            case "dm_cabinet": return RestObjectType.cabinet.rawValue
            case "dm_folder": return RestObjectType.folder.rawValue
            case "dm_document": return RestObjectType.document.rawValue
            case "dm_sysobject": return RestObjectType.sysObject.rawValue
            case "dm_group": return RestObjectType.group.rawValue
            case "dm_user": return RestObjectType.user.rawValue
            default: return RestObjectType.sysObject.rawValue
        }
    }
}


enum RestObjectType : String {
    case repository = "Repository"
    case document = "Document"
    case folder = "Folder"
    case cabinet = "Cabinet"
    case sysObject = "Sysobject"
    case group = "Group"
    case user = "User"
}

