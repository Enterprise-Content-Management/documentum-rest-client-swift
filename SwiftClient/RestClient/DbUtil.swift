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
    static let TABLE_BASIC = "basic"
    static let attr = Expression<String>("attr")
    static let value = Expression<String>("value")
    
    static private func getConnectionOfDb(name: String) -> Connection? {
        let paths = NSBundle.mainBundle().pathsForResourcesOfType("db", inDirectory: nil)
        let manager = NSFileManager.defaultManager()
        for path in paths {
            if name == manager.displayNameAtPath(path) {
                let db = try! Connection(path)
                return db
            }
        }
        return nil
    }
    
    static private func getFilteredTable(tableName: String  = TABLE_BASIC, attrName: String) -> Table {
        let basicTable = Table(tableName)
        let filteredTable = basicTable.filter(attr == attrName)
        return filteredTable
    }
    
    static func getValueFromTable(tableName: String  = TABLE_BASIC, attrName: String) -> String? {
        let db = getConnectionOfDb(DATABASE)
        let table = getFilteredTable(attrName: attrName)
        for item in try! db!.prepare(table) {
            return item[value]
        }
        return nil
    }
    
    static func updateValueFromTable(tableName: String = TABLE_BASIC, attrName: String, attrValue: String) {
        let db = getConnectionOfDb(DATABASE)
        let table = getFilteredTable(attrName: attrName)
        try! db!.run(table.update(value <- attrValue))
    }
}




