//
//  RRabacRole+RRabacPermission.swift
//  
//
// Created by Ido Rabin for Bricks on 17/1/2024.
import Foundation
import Vapor
import Fluent
import MNUtils
//import DSLogger


final class RRabacRolePermission: RRabacModel {
    static var mnuidTypeStr: String = RRabacMNUIDType.rolePermission
    static let schema = "rrabac_role_permissions"

    // MARK: CodingKeys
    enum CodingKeys : String, CodingKey, CaseIterable {
        case id = "id"
        case role = "role_id"
        case permission = "permission_id"
        
        var fieldKey : FieldKey {
            return .string(self.rawValue)
        }
    }
    
    // MARK: Properties
    @ID(key: .id)
    var id: UUID?
    var mnUID: MNUID? {
        return RRabacRolePermissionUID(uid: id!, typeStr: RRabacMNUIDType.rolePermission)
    }
    
    @Parent(key: CodingKeys.role.fieldKey)
    var role: RRabacRole

    @Parent(key: CodingKeys.permission.fieldKey)
    var permission: RRabacPermission

    //  MARK: Lifecycle
    // Vapor migration requires empty init
    init() {}

    init(roleID: UUID, permissionID: UUID) {
        self.$role.id = roleID
        self.$permission.id = permissionID
    }
    
    // MARK: Migration
    public func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(Self.schema)
            .id() // primary key
            .field(CodingKeys.role.fieldKey,       .uuid,  .required)
            .field(CodingKeys.permission.fieldKey, .uuid,  .required)
            .ignoreExisting().create()
    }
    
    public func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(Self.schema).delete()
    }
}
