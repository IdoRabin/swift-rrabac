//
//  MNUIDType+RRabac.swift
//  
//
// Created by Ido Rabin for Bricks on 17/1/2024.

import Foundation
import MNUtils

public struct RRabacMNUIDType /* RRabac */ {
    // "Cases"
    public static let permission       = "RRPerm"
    public static let permissionResult = "RRPerm_Rslt"
    public static let role             = "RRRole"
    public static let user             = "RRUser"
    public static let group            = "RRGrup"
    public static let roleGroup        = "RRole_Grup"
    public static let rolePermission   = "RRole_Perm"
    public static let userRole         = "RRUsr_Role"
    public static let userGroup        = "RRUsr_Grup"
    public static let historyItem      = "RRHist_Item"
}

public class RRabacPermissionUID : MNUID {
    override public var type : String { return RRabacMNUIDType.permission }
    override public func setType(str:String? = RRabacMNUIDType.permission) {/* does nothing ; */}
}

public class RRabacPermissionResultUID : MNUID {
    override public var type : String { return RRabacMNUIDType.permissionResult }
    override public func setType(str:String? = RRabacMNUIDType.permissionResult) {/* does nothing ; */}
}

public class RRabacRoleUID : MNUID {
    override public var type : String { return RRabacMNUIDType.role }
    override public func setType(str:String? = RRabacMNUIDType.role) {/* does nothing ; */}
}

public class RRabacUserUID : MNUID {
    override public var type : String { return RRabacMNUIDType.user }
    override public func setType(str:String? = RRabacMNUIDType.user) {/* does nothing ; */}
}

public class RRabacGroupUID : MNUID {
    override public var type : String { return RRabacMNUIDType.group }
    override public func setType(str:String? = RRabacMNUIDType.group) {/* does nothing ; */}
}

public class RRabacRoleGroupUID : MNUID {
    override public var type : String { return RRabacMNUIDType.roleGroup }
    override public func setType(str:String? = RRabacMNUIDType.roleGroup) {/* does nothing ; */}
}

public class RRabacRolePermissionUID : MNUID {
    override public var type : String { return RRabacMNUIDType.rolePermission }
    override public func setType(str:String? = RRabacMNUIDType.rolePermission) {/* does nothing ; */}
}

public class RRabacUserRoleUID : MNUID {
    override public var type : String { return RRabacMNUIDType.userRole }
    override public func setType(str:String? = RRabacMNUIDType.userRole) {/* does nothing ; */}
}

public class RRabacUserGroupUID : MNUID {
    override public var type : String { return RRabacMNUIDType.userGroup }
    override public func setType(str:String? = RRabacMNUIDType.userGroup) {/* does nothing ; */}
}

public class RRabacHistoryItemUID : MNUID {
    override public var type : String { return RRabacMNUIDType.historyItem }
    override public func setType(str:String? = RRabacMNUIDType.historyItem) {/* does nothing ; */}
}
