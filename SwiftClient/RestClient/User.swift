//
//  User.swift
//  RestClient
//
//  Created by Song, Michyo on 6/30/16.
//  Copyright © 2016 EMC Corporation. All rights reserved.
//

import UIKit

class User: RestObject {
    
    let userPrivilegesTable: [UserPrivilege] = [
        .NONE, .CREATE_TYPE, .CREATE_CABINET, .CREATE_GROUP, .SYSADMIN, .SUPERUSER
    ]
    
    func getReadableUSerPrivilege() -> String {
        return getReadableUserPrivilege(getProperty(.USER_PRIVILEGES) as! Int)
    }
    
    private func getReadableUserPrivilege(userPrivilege: Int) -> String {
        if userPrivilege == 0 {
            return readablePrivilege(userPrivilegesTable[0])
        }
        let binary = String(userPrivilege, radix: 2)
        let length = binary.characters.count
        if length > 4 {
            return readablePrivilege(userPrivilegesTable[5])
        } else if length == 4 {
            return readablePrivilege(userPrivilegesTable[4])
        } else if length == 3 {
            switch binary {
            case "100":
                return readablePrivilege(userPrivilegesTable[3])
            case "101":
                return "Create Group and Type"
            case "110":
                return "Create Group and Cabinet"
            case "111":
                return "Create Group, Cabinet and Type"
            default:
                break
            }
        } else if length == 2 {
            switch binary {
            case "10":
                return readablePrivilege(userPrivilegesTable[2])
            case "11":
                return "Create Cabinet and Type"
            default:
                break
            }
        } else if length == 1{
            return readablePrivilege(userPrivilegesTable[1])
        }
        return ""
    }
    
    private func readablePrivilege(privilege: UserPrivilege) -> String {
        switch privilege {
        case .NONE:
            return "None"
        case .CREATE_TYPE:
            return "Create Type"
        case .CREATE_CABINET:
            return "Create Cabinet"
        case .CREATE_GROUP:
            return "Create Group"
        case .SYSADMIN:
            return "System Administrator"
        case .SUPERUSER:
            return "Super User"
        }
    }

}

enum UserPrivilege : Int {
    case NONE = 0
    case CREATE_TYPE = 1
    case CREATE_CABINET = 2
    case CREATE_GROUP = 4
    case SYSADMIN = 8
    case SUPERUSER = 16
}
