//
//  MNUIDType+RRabac.swift
//  
//
//  Created by Ido on 04/06/2023.
//

import Foundation
import MNUtils

public extension MNUIDType /* RRabac */ {
    // "Cases"
    static let permission      = "RRPerm"
    static let role            = "RRRole"
    static let user            = "RRUser"
    static let group           = "RRGrup"
    static let roleGroup       = "RRole_Grup"
    static let rolePermission  = "RRole_Perm"
    static let userRole        = "RRUsr_Role"
    static let userGroup       = "RRUsr_Grup"
}

public class RRabacPermissionUID : MNUID {
    override public var type : String { return MNUIDType.permission }
    override public func setType(str:String? = MNUIDType.permission) {/* does nothing ; */}
}

public class RRabacRoleUID : MNUID {
    override public var type : String { return MNUIDType.role }
    override public func setType(str:String? = MNUIDType.role) {/* does nothing ; */}
}

public class RRabacUserUID : MNUID {
    override public var type : String { return MNUIDType.user }
    override public func setType(str:String? = MNUIDType.user) {/* does nothing ; */}
}

public class RRabacGroupUID : MNUID {
    override public var type : String { return MNUIDType.group }
    override public func setType(str:String? = MNUIDType.group) {/* does nothing ; */}
}

public class RRabacRoleGroupUID : MNUID {
    override public var type : String { return MNUIDType.roleGroup }
    override public func setType(str:String? = MNUIDType.roleGroup) {/* does nothing ; */}
}

public class RRabacRolePermissionUID : MNUID {
    override public var type : String { return MNUIDType.rolePermission }
    override public func setType(str:String? = MNUIDType.rolePermission) {/* does nothing ; */}
}

public class RRabacUserRoleUID : MNUID {
    override public var type : String { return MNUIDType.userRole }
    override public func setType(str:String? = MNUIDType.userRole) {/* does nothing ; */}
}

public class RRabacUserGroupUID : MNUID {
    override public var type : String { return MNUIDType.userGroup }
    override public func setType(str:String? = MNUIDType.userGroup) {/* does nothing ; */}
}
