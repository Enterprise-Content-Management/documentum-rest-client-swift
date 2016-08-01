//
//  RestUriBuilder.swift
//  RestClient
//
//  Created by Song, Michyo on 3/29/16.
//  Copyright © 2016 EMC Corporation. All rights reserved.
//

import UIKit

class RestUriBuilder {
    static let rootUrl = DbUtil.getValueFromTable(attrName: "rooturl")!
    static let serviceContext = DbUtil.getValueFromTable(attrName: "context")!
    static let services = "/services"
    static let repositories = "/repositories"
    
    struct currentLoginCredential {
        static var userName: String!
        static var password: String!
    }
    
    static func getCurrentLoginAuthString() -> NSString {
        return "\(currentLoginCredential.userName!):\(currentLoginCredential.password!)" as NSString
    }
    
    static func getCurrentUserName() -> String {
        return currentLoginCredential.userName
    }
    
    static func getServicesUrl() -> String {
        return rootUrl + serviceContext + services
    }
    
    static func getRepositoriesUrl() -> String {
        return rootUrl + serviceContext + repositories
    }
    
    static func inlineParam() -> [String : String] {
        let param = ["inline": "true"]
        return param
    }
    
    static func pageParam(itemsPerPage: NSInteger, pageNo: NSInteger) -> [String : String] {
        let param = ["items-per-page": String(itemsPerPage), "page": String(pageNo)]
        return param
    }
    
    private static func convertCabinetsToFolders(id: String) -> String {
        return id.stringByReplacingOccurrencesOfString("cabinets", withString: "folders")
    }
    
    static func getObjectId(objectUrl: String) -> String {
        let array = objectUrl.componentsSeparatedByString("/")
        return array[array.count - 1]
    }
}

enum LinkRel: String {
    case selfRel = "self"
    case repositories = "http://identifiers.emc.com/linkrel/repositories"
    case cabinets = "http://identifiers.emc.com/linkrel/cabinets"
    case delete = "http://identifiers.emc.com/linkrel/delete"
    case objects = "http://identifiers.emc.com/linkrel/objects"
    case edit = "edit"
    case content = "http://identifiers.emc.com/linkrel/primary-content"
    case enclosure = "enclosure"
    case checkout = "http://identifiers.emc.com/linkrel/checkout"
    case checkinMajor = "http://identifiers.emc.com/linkrel/checkin-next-major"
    case checkinMinor = "http://identifiers.emc.com/linkrel/checkin-next-minor"
    case parent = "parent"
    case currentUser = "http://identifiers.emc.com/linkrel/current-user"
    
    static func getLink(linkRel: String, links: NSArray) -> String? {
        var downloadUrl: String?
        for link in links {
            let link = link as! Dictionary<String, String>
            if link["rel"] == linkRel {
                downloadUrl = link["href"]
            }
        }
        return downloadUrl
    }
}
