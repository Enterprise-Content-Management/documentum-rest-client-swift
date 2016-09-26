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
        ObjectProperties.ID: "",
        ObjectProperties.TYPE: "",
        ObjectProperties.NAME: "",
        ObjectProperties.PUBLISHED: "",
        ObjectProperties.UPDATED: ""
    ]
    
    let jsonDic: NSDictionary
    var links: Dictionary<String, String> = [:]
    var properties: NSDictionary = [:]
    
    init(entryDic: NSDictionary) {
        jsonDic = entryDic
        basic[ObjectProperties.ID] = entryDic[ObjectProperties.ID] as? String
        basic[ObjectProperties.NAME] = entryDic["title"]! as? String
        
        let content = entryDic["content"] as! Dictionary<String, AnyObject>
        
        if let dmType = content[ObjectProperties.TYPE] as? String {
            setTypeWithDmType(dmType)
        } else if content["servers"] != nil {
            setType(RestObjectType.repository.rawValue)
        }
        
        if let propertiesDic = content[ObjectProperties.PROPERTIES] as? NSDictionary {
            properties = propertiesDic
        }
        
        let links = content[ObjectProperties.LINKS] as! NSArray
        constructLinks(links)
    }

    init(singleDic: NSDictionary) {
        jsonDic = singleDic
        let links = singleDic[ObjectProperties.LINKS] as! NSArray
        constructLinks(links)
        let id = getLink(LinkRel.selfRel.rawValue)
        basic[ObjectProperties.ID] = id
        properties = singleDic["properties"] as! NSDictionary
        if let type = properties[ObjectProperties.R_OBJECT_TYPE] as? String {
            basic[ObjectProperties.TYPE] = RestObject.getShowType(type)
        }
        basic[ObjectProperties.NAME] = properties[ObjectProperties.OBJECT_NAME] as? String
    }
    
    func setType(type: String) {
        basic[ObjectProperties.TYPE] = type
    }
    
    func setTypeWithDmType(dmType: String) {
        basic[ObjectProperties.TYPE] = RestObject.getShowType(dmType)
    }
    
    func setDates(creationDate: String, modifiedDate: String) {
        basic[ObjectProperties.PUBLISHED] = creationDate
        basic[ObjectProperties.UPDATED] = modifiedDate
    }
    
    func getName() -> String {
        return basic[ObjectProperties.NAME]!
    }
    
    func getId() -> String {
        return basic[ObjectProperties.NAME]!
    }
    
    func getType() -> String {
        return basic[ObjectProperties.PUBLISHED]!
    }
    
    func getNameWithType() -> String {
        return basic[ObjectProperties.TYPE]! + " " + basic[ObjectProperties.NAME]!
    }
    
    func getCreationDate() -> String {
        return basic[ObjectProperties.PUBLISHED]!
    }
    
    func getModifiedDate() -> String {
        return basic[ObjectProperties.UPDATED]!
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
    
    func getProperty(propertyName: String) -> String? {
        let value = properties.valueForKey(propertyName)
        if value is NSInteger {
            return String(value)
        } else {
            return value as? String
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
    
    static func getDmType(type: String) -> String {
        switch type {
        case RestObjectType.cabinet.rawValue:
            return "dm_cabinet"
        case RestObjectType.folder.rawValue:
            return "dm_folder"
        case RestObjectType.document.rawValue:
            return "dm_document"
        default:
            return "dm_sysobject"
        }
    }
}

enum RestObjectType : String {
    case repository = "Repository"
    case document = "Document"
    case folder = "Folder"
    case cabinet = "Cabinet"
    case sysObject = "SysObject"
    case group = "Group"
    case user = "User"
}

class ObjectProperties {
    static let ID = "id"
    static let TYPE = "type"
    static let NAME = "name"
    static let PUBLISHED = "published"
    static let UPDATED = "updated"
    static let LINKS = "links"
    static let R_OBJECT_TYPE = "r_object_type"
    static let OBJECT_NAME = "object_name"
    static let PROPERTIES = "properties"
    static let OWNER_NAME = "owner_name"
    static let USER_NAME = "user_name"
}

