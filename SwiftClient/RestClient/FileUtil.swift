//
//  FileUtil.swift
//  RestClient
//
//  Created by Song, Michyo on 6/6/16.
//  Copyright © 2016 EMC Corporation. All rights reserved.
//

import UIKit

class FileUtil {
    
    static let fileManager = NSFileManager.defaultManager()
    
    static func isDownloaded(objectId: String) -> Bool {
        let path = getFilePathFromId(objectId)
        let flag = fileManager.fileExistsAtPath(path)
        return flag
    }
    
    static func deleteFile(objectId: String) {
        let path = getFilePathFromId(objectId)
        if !isDownloaded(objectId) {
            return
        }
        do {
            try fileManager.removeItemAtPath(path)
            printLog("Removed file at path of \(path)")
        } catch {
            printError("Error to remove file which id is \(objectId) on this device")
        }
    }
    
    static func getFileUrlFromId(objectId: String) -> NSURL {
        let directoryUrl = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
        let pathComponent = objectId
        let fileUrl = directoryUrl.URLByAppendingPathComponent(pathComponent)
        return fileUrl
    }
    
    static private func getFilePathFromId(objectId: String) -> String {
        let url = getFileUrlFromId(objectId)
        return url.path!
    }
    
    static func getSaveToUrl(objectId: String) -> NSURL {
        let directoryUrl = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
        let pathComponent = objectId
        return directoryUrl.URLByAppendingPathComponent(pathComponent)
    }
}
