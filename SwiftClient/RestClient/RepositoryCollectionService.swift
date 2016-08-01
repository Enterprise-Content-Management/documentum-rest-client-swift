//
//  RepositoryCollectionService.swift
//  RestClient
//
//  Created by Song, Michyo on 3/30/16.
//  Copyright © 2016 EMC Corporation. All rights reserved.
//

import UIKit
import SwiftyJSON

class RepositoryCollectionService : RestCollectionService {
    
    override init() {
        super.init()
    }
    
    override func getService(pageNo: NSInteger, completionHandler: (NSArray?, Error?) -> ()) {
        RestService.getRepositoriesUrl { url, error in
            if let error = error {
                completionHandler(nil, error)
            } else if let url = url {
                self.url = url
                RestService.getResponseWithParams(self.url!, params: self.getParams(pageNo), completionHandler: completionHandler)
            }
        }
    }
    
    override func constructRestObject(dic: Dictionary<String, AnyObject>) -> RestObject {
        let restObject = super.constructRestObject(dic)
        restObject.setType(RestObjectType.repository.rawValue)
        return restObject
    }
}
