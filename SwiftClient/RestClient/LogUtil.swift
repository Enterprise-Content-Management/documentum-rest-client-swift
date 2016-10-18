//
//  LogUtil.swift
//  RestClient
//
//  Created by Song, Michyo on 10/18/16.
//  Copyright © 2016 EMC Corporation. All rights reserved.
//

import SwiftLog

class LogUtil {
    
    internal class var log: LogUtil {
        struct Static {
            static let instance: LogUtil = LogUtil.init()
        }
        return Static.instance
    }
    
    private init() {
        Log.logger.name = "RestSampleClientInIOS.log"
        Log.logger.maxFileSize = 2048
        Log.logger.maxFileCount = 8
    }
    
    
    static func print(message: String) {
        logw(message)
    }
}

public func printLog(message: String) {
    LogUtil.print("[LOG]\t\(message)")
}

public func printError(message: String) {
    LogUtil.print("[ERR] \t\(message)")
}