//
//  RestServiceEnhance.swift
//  RestClient
//
//  Created by Song, Michyo on 6/17/16.
//  Copyright © 2016 EMC Corporation. All rights reserved.
//

import UIKit
import Alamofire

class RestServiceEnhance : RestService {
    
    static func getDownloadUrl(object: RestObject, doAfterDownloaded: (String, NSDictionary, NSArray)-> Void) -> Void {
        let contentUrl = object.getLink(LinkRel.content.rawValue)
        RestService.getPropertiesAndLinks(Alamofire.Method.GET, url: contentUrl!) { properties, links, error in
            if error == nil {
                if let downloadUrl = LinkRel.getLink(LinkRel.enclosure.rawValue, links: links!) {
                    print("DownloadUrl for object \(object.getName()) is \(downloadUrl)")
                    doAfterDownloaded(downloadUrl, properties!, links!)
                }
            }
        }
    }
}
