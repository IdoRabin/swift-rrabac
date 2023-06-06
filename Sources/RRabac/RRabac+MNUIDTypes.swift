//
//  MNUIDTypes.swift
//  
//
//  Created by Ido on 04/06/2023.
//

import Foundation
import MNUtils

public enum RRabacMNUIDTypes : String {
    case permission      = "RRPerm"
    case role            = "RRRole"
    case user            = "RRUser"
    case group           = "RRGrup"
}

// RRabacPermission
// RRabacRole
// RRabacUser
// RRabacGroup

public class RRabacPermissionUID : MNUID {
    override public var type : String { return RRabacMNUIDTypes.permission.rawValue }
    override public func setType(str:String? = RRabacMNUIDTypes.permission.rawValue) {/* does nothing ; */}
}

public class RRabacRoleUID : MNUID {
    override public var type : String { return RRabacMNUIDTypes.role.rawValue }
    override public func setType(str:String? = RRabacMNUIDTypes.role.rawValue) {/* does nothing ; */}
}

public class RRabacUserUID : MNUID {
    override public var type : String { return RRabacMNUIDTypes.user.rawValue }
    override public func setType(str:String? = RRabacMNUIDTypes.user.rawValue) {/* does nothing ; */}
}

public class RRabacGroupUID : MNUID {
    override public var type : String { return RRabacMNUIDTypes.group.rawValue }
    override public func setType(str:String? = RRabacMNUIDTypes.group.rawValue) {/* does nothing ; */}
}
