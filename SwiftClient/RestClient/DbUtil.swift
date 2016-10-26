//
//  DbUtil.swift
//  RestClient
//
//  Created by Song, Michyo on 6/29/16.
//  Copyright © 2016 EMC Corporation. All rights reserved.
//

import Foundation
import SQLite

class DbUtil {
    static let DATABASE = "database.db"
    static let DATABASE_PATH = NSURL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]).URLByAppendingPathComponent(DATABASE).path!
    static let TABLE_BASIC = "basic"
    static let TABLE_DQL_HISTORY = "dql_history"
    static let id = Expression<Int64>("id")
    static let attr = Expression<String>("attr")
    static let value = Expression<String>("value")
    static let time = Expression<String>("time")
    static let dql = Expression<String>("dql")
    
    static let ATTR_ROOTURL     = "rooturl"
    static let ATTR_CONTEXT     = "context"
    static let ATTR_AUTO        = "shouldautologin"
    static let ATTR_USERNAME    = "username"
    static let ATTR_PASSWORD    = "password"
    static let ATTR_REMEMBER    = "shouldremember"
    static let ATTR_TIME        = "time"
    static let ATTR_DQL         = "dql"
    
    static private func getConnectionOfDb(name: String = DATABASE) -> Connection? {
        let manager = NSFileManager.defaultManager()
        if !manager.isReadableFileAtPath(DATABASE_PATH) {
            copyDbToDocument()
        }
        
        do {
            let db = try Connection(DATABASE_PATH)
            return db
        } catch {
            printError("Error in open connection for database")
        }
        return nil
    }
    
    static func copyDbToDocument() {
        let paths = NSBundle.mainBundle().pathsForResourcesOfType("db", inDirectory: nil)
        let manager = NSFileManager.defaultManager()
        var originalPath: String = ""
        for path in paths {
            if DATABASE == manager.displayNameAtPath(path) {
                originalPath = path
                break
            }
        }
        
        if !manager.isReadableFileAtPath(DATABASE_PATH) {
            do {
                try manager.copyItemAtPath(originalPath, toPath: DATABASE_PATH)
                printLog("Successfully copy database to path: \(DATABASE_PATH)")
            } catch {
                printError("Error in copy database")
            }
        }
    }
    
    static private func getFilteredTable(tableName: String  = TABLE_BASIC, attrName: String) -> Table {
        let basicTable = Table(tableName)
        let filteredTable = basicTable.filter(attr == attrName)
        return filteredTable
    }
    
    static func getValueFromTable(tableName: String  = TABLE_BASIC, attrName: String) -> String? {
        let db = getConnectionOfDb()
        let table = getFilteredTable(attrName: attrName)
        for item in try! db!.prepare(table) {
            return item[value]
        }
        return nil
    }
    
    static func updateValueFromTable(tableName: String = TABLE_BASIC, attrName: String, attrValue: String) {
        let db = getConnectionOfDb()
        let table = getFilteredTable(attrName: attrName)
        try! db!.run(table.update(value <- attrValue))
    }
    
    static func insertDqlHistory(dateValue: NSDate, dqlValue: String) -> Int64 {
        let db = getConnectionOfDb()
        let dqlTable = Table(TABLE_DQL_HISTORY)
        let timeValue = Utility.getReadableDate(dateValue)
        let insert = dqlTable.insert(time <- timeValue, dql <- dqlValue)
        printLog("Insert dql history with TIME = \(timeValue), DQL = \(dqlValue)")
        return try! db!.run(insert)
    }
    
    static func getAllDqlHistories() -> AnySequence<Row> {
        let db = getConnectionOfDb()
        let dqlTable = Table(TABLE_DQL_HISTORY)
        return try! db!.prepare(dqlTable)
    }
    
    static func deleteDqlHistory(idValue: Int64) {
        let db = getConnectionOfDb()
        let dqlTable = Table(TABLE_DQL_HISTORY)
        let history = dqlTable.filter(id == idValue)
        try! db!.run(history.delete())
    }
}




