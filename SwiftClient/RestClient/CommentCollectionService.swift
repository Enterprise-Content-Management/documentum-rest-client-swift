//
//  CommentCollectionService.swift
//  RestClient
//
//  Created by Song, Michyo on 10/9/16.
//  Copyright © 2016 EMC Corporation. All rights reserved.
//

import UIKit

class CommentCollectionService: RestCollectionService {
    
    override func getService(pageNo: NSInteger, completionHandler: (NSArray?, Error?) -> ()) {
        super.getService(pageNo, completionHandler: completionHandler)
        
        RestService.getResponseWithAuthAndParam(url, params: getParams(pageNo), completionHandler: completionHandler)

    }
    
    override func getEntries(pageNo: NSInteger, thisViewController: UIViewController, completionHandler: ([RestObject], Bool) -> ()) {
        getService(pageNo) { entries, error in
            if let error = error {
                let errorMsg = error.message
                if error.errorCode == "E_SERVICE_NOT_INSTALLED" {
                    let infoView = thisViewController as! InfoViewController
                    if let index = infoView.shownSections.indexOf(2) {
                        infoView.shownSections.removeAtIndex(index)
                        infoView.tableView.reloadData()
                    }
                    infoView.aiHelper.stopActivityIndicator()
                    ErrorAlert.show(errorMsg, controller: thisViewController, dismissViewController: false)
                }
                ErrorAlert.show(errorMsg, controller: thisViewController)
                return
            } else {
                var restObjects = [RestObject]()
                var isLastPage = true
                if let entries = entries {
                    for entry in entries {
                        let dic = entry as! Dictionary<String, AnyObject>
                        let restObject = self.constructRestObject(dic)
                        restObjects.append(restObject)
                    }
                    isLastPage = entries.count < RestService.itemsPerPage
                }
                completionHandler(restObjects, isLastPage)
            }
        }
    }
    
    override func constructRestObject(dic: Dictionary<String, AnyObject>) -> RestObject {
        let restObject = Comment(entryDic: dic)
        return restObject
    }
    
    func getCommentsAndReplies(pageNo: NSInteger, thisViewController: UIViewController, completionHandler: ([RestObject], Bool) -> ()) {
        getEntries(pageNo, thisViewController: thisViewController) { objects, isLastPage in
            var flag = 0
            var comments = objects
            if objects.isEmpty {
                completionHandler(comments, isLastPage)
            }
            for i in 0..<objects.count {
                let comment = comments[i]
                let repliesUrl = comment.getLink(LinkRel.replies.rawValue)!
                RestService.getResponseWithAuthAndParam(repliesUrl, params: self.getParams(1)) { array, error in
                    if let error = error {
                        ErrorAlert.show(error.message, controller: thisViewController)
                        return
                    } else {
                        flag += 1
                        if let replies = array {
                            for j in 0..<replies.count {
                                let dic = replies[j] as! NSDictionary
                                let reply = Comment(entryDic: dic)
                                reply.setParentComment(comment as? Comment)
                                comments.insert(reply, atIndex: i + j + 1)
                            }
                        }
                        if flag == objects.count {
                            completionHandler(comments, isLastPage)
                        }
                    }
                }
            }
        }
    }
}
