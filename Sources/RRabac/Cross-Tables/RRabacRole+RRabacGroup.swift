//
//  RRabacRole+RRabacGroup.swift
//  RRabac
//
// Created by Ido Rabin for Bricks on 17/1/2024.

import Foundation
import Vapor
import Fluent
import MNUtils
//import DSLogger


final class RRabacRoleGroup: RRabacModel {
    
    public static var mnuidTypeStr: String = RRabacMNUIDType.roleGroup
    static let schema = "rrabac_role_groups"
    
    // MARK: CodingKeys
    enum CodingKeys : String, CodingKey, CaseIterable {
        case id = "id"
        case role = "role_id"
        case group = "group_id"
        
        var fieldKey : FieldKey {
            return .string(self.rawValue)
        }
    }
    
    // MARK: Properties
    @ID(key: .id)
    var id: UUID?
    var mnUID: MNUID? {
        return RRabacRoleGroupUID(uid: id!, typeStr: RRabacMNUIDType.roleGroup)
    }
    
    @Parent(key: CodingKeys.role.fieldKey)
    var role: RRabacRole

    @Parent(key: CodingKeys.group.fieldKey)
    var group: RRabacGroup

    //  MARK: Lifecycle
    // Vapor migration requires empty init
    init() {}

    init(roleID: UUID, groupId: UUID) {
        self.$role.id = roleID
        self.$group.id = groupId
    }
    
    // MARK: Migration
    public func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(Self.schema)
            .id() // primary key
            .field(CodingKeys.role.fieldKey,  .uuid,  .required)
            .field(CodingKeys.group.fieldKey, .uuid,  .required)
            .ignoreExisting().create()
    }
    
    public func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(Self.schema).delete()
    }
}
