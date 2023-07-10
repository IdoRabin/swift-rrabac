//
//  RRabacRole+RRabacGroup.swift
//  RRabac
//
//  Created by Ido on 04/06/2023.
//

import Foundation
import Vapor
import Fluent
import MNUtils
//import DSLogger


final public class RRabacRoleGroup: RRabacModel {
    
    public static let schema = "rrabac_role_groups"
    
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
    public var id: UUID?
    public var mnUID: MNUID? {
        return RRabacRoleGroupUID(uid: id!, typeStr: MNUIDType.roleGroup)
    }
    
    // MARK: Fluent Pivot table (two @Parents are required)
    @Parent(key: CodingKeys.role.fieldKey)
    var role: RRabacRole

    @Parent(key: CodingKeys.group.fieldKey)
    var group: RRabacGroup

    //  MARK: Lifecycle
    // Vapor migration requires empty init
    public init() {}

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
            .unique(on: CodingKeys.role.fieldKey, CodingKeys.group.fieldKey)
            .ignoreExisting().create()
    }
    
    public func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(Self.schema).delete()
    }
}
