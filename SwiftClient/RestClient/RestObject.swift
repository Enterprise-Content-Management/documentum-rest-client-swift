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
        ObjectProperties.ID.rawValue: "",
        ObjectProperties.TYPE.rawValue: "",
        ObjectProperties.NAME.rawValue: "",
        ObjectProperties.PUBLISHED.rawValue: "",
        ObjectProperties.UPDATED.rawValue: ""
    ]
    
    let jsonDic: NSDictionary
    var links: Dictionary<String, String> = [:]
    var properties: Dictionary<String, AnyObject> = [:]
    
    init(entryDic: NSDictionary) {
        jsonDic = entryDic
        setBasic(.ID, value: entryDic[ObjectProperties.ID.rawValue] as! String)
        setBasic(.NAME, value: entryDic["title"]! as! String)
        setUpdated(entryDic[ObjectProperties.UPDATED.rawValue] as! String)
        setPublished(entryDic[ObjectProperties.PUBLISHED.rawValue] as! String)
        
        let content = entryDic["content"] as! Dictionary<String, AnyObject>
        if let propertiesDic = content[ObjectProperties.PROPERTIES.rawValue] as? NSDictionary {
            properties = propertiesDic as! Dictionary<String, AnyObject>
        }
        
        let links = content[ObjectProperties.LINKS.rawValue] as! NSArray
        constructLinks(links)
        
        setTypeByDic(content)
    }

    init(singleDic: NSDictionary) {
        jsonDic = singleDic
        let links = singleDic[ObjectProperties.LINKS.rawValue] as! NSArray
        constructLinks(links)
        setBasic(.ID, value: getLink(LinkRel.selfRel.rawValue)!)
        
        if let pros = singleDic["properties"] as? Dictionary<String, AnyObject>  {
            properties = pros
            setUpdated(getProperty(.R_MODIFY_DATE) as! String)
        }
        
        if let type = singleDic["type"] as? String {
            setTypeWithDmType(type)
        }
        else if let type = getProperty(.R_OBJECT_TYPE) as? String {
            setTypeWithDmType(type)
        }
        if let name = getProperty(.OBJECT_NAME) as? String {
            setBasic(.NAME, value: name)
        } else if let name = getProperty(.USER_NAME) as? String {
            setBasic(.NAME, value: name)
        }
        
        if let published = getProperty(.R_CREATION_DATE) as? String {
            setPublished(published)
        }
    }
    
    init(searchDic: NSDictionary) {
        jsonDic = searchDic
        
        setUpdated(searchDic[ObjectProperties.UPDATED.rawValue] as! String)
        setPublished(searchDic[ObjectProperties.PUBLISHED.rawValue] as! String)
        
        let links = searchDic[ObjectProperties.LINKS.rawValue] as! NSArray
        constructLinks(links)
        let content = searchDic["content"] as! Dictionary<String, AnyObject>
        properties = content[ObjectProperties.PROPERTIES.rawValue] as! Dictionary<String, AnyObject>
        
        setBasic(.ID, value: getLink(LinkRel.edit.rawValue)!)
        setBasic(.NAME, value: getProperty(.OBJECT_NAME) as! String)
        
        setTypeByDic(content)
    }
    
    private func setTypeByDic(contentDic: NSDictionary) {
        if let dmType = contentDic[ObjectProperties.TYPE.rawValue] as? String {
            setTypeWithDmType(dmType)
        } else if contentDic["servers"] != nil {
            setType(RestObjectType.repository.rawValue)
        } else if let name = contentDic["name"] as? String {
            if name.capitalizedString == RestObjectType.group.rawValue {
                setType(RestObjectType.group.rawValue)
            } else if name.capitalizedString == RestObjectType.user.rawValue {
                setType(RestObjectType.user.rawValue)
            }
        }
    }
    
    // MARK: - Getters and Setters
    private func setBasic(name: ObjectProperties, value: String) {
        basic[name.rawValue] = value
    }
    
    private func getBasic(name: ObjectProperties) -> String {
        return basic[name.rawValue]!
    }
    
    func setType(type: String) {
        setBasic(.TYPE, value: type)
    }
    
    func setTypeWithDmType(dmType: String) {
        setBasic(.TYPE, value: RestObject.getShowType(dmType))
    }
    
    func setPublished(published: String) {
        setBasic(.PUBLISHED, value: published)
    }
    
    func setUpdated(updated: String) {
        setBasic(.UPDATED, value: updated)
    }
    
    func getName() -> String {
        return getBasic(.NAME)
    }
    
    func getId() -> String {
        return getBasic(.ID)
    }
    
    func getType() -> String {
        return getBasic(.TYPE)
    }
    
    func getNameWithType() -> String {
        return getBasic(.TYPE) + " " + getBasic(.NAME)
    }
    
    func getPublished() -> String {
        return getBasic(.PUBLISHED)
    }
    
    func getUpdated() -> String {
        return getBasic(.UPDATED)
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
    
    func getProperty(propertyName: String) -> AnyObject? {
        return properties[propertyName]
    }
    
    func getProperty(propertyName: ObjectProperties) -> AnyObject? {
        return getProperty(propertyName.rawValue)
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
    case comment = "Comment"
    case reply = "Reply"
}

enum ObjectProperties: String {
    case ID = "id"
    case TYPE = "type"
    case NAME = "name"
    case PUBLISHED = "published"
    case UPDATED = "updated"
    case LINKS = "links"
    case R_OBJECT_TYPE = "r_object_type"
    case OBJECT_NAME = "object_name"
    case PROPERTIES = "properties"
    case OWNER_NAME = "owner_name"
    case USER_NAME = "user_name"
    case R_MODIFY_DATE = "r_modify_date"
    case R_CREATION_DATE = "r_creation_date"
}

