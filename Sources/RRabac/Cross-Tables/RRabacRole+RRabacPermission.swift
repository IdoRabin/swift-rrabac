//
//  RRabacRole+RRabacPermission.swift
//  
//
//  Created by Ido on 01/06/2023.
//
import Foundation
import Vapor
import Fluent
//import MNUtils
//import DSLogger


final class RRabacRolePermission: Model {
    
    static let schema = "role_permissions"

    @ID(key: .id)
    var id: UUID?

    @Parent(key: "role_id")
    var role: RRabacRole

    @Parent(key: "permission_id")
    var permission: RRabacPermission

    init() {}

    init(roleID: UUID, permissionID: UUID) {
        self.$role.id = roleID
        self.$permission.id = permissionID
    }
}
