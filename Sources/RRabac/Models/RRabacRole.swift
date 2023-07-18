//
//  RRabacRole.swift
//  
//
//  Created by Ido on 01/06/2023.
//

import Foundation
import Vapor
import Fluent
import MNUtils
import DSLogger

final public class RRabacRole: RRabacModel {
    public static let mnuidStr = "RRBC_ROL"
    public  static let schema = "rrabac_roles"
    
    // MARK: CodingKeys
    enum CodingKeys : String, CodingKey, CaseIterable {
        case id = "id"
        case title = "title"
        case users = "user_ids"
        case parent = "parent_role_id"
        case children = "childre_role_ids"
        case addedPermissions = "added_permission_ids"
        case revokedPermissions = "revoked.permission_ids"
        case groups = "groups_ids"
        
        var fieldKey : FieldKey {
            return .string(self.rawValue)
        }
    }
    
    // MARK: Properties
    @ID(key: .id)
    public var id: UUID?
    
    @Field(key: CodingKeys.title.fieldKey)
    public var title: String // name of the role

    /// Permissions added for the user in addition to the permissions given by the user roles.
    @Field(key: CodingKeys.addedPermissions.fieldKey)
    public var addedPermissions: [RRabacPermission]
    
    /// Permissions revoked for the user overriding all roles and groups the user is associated with
    @Field(key: CodingKeys.revokedPermissions.fieldKey)
    public var revokedPermissions: [RRabacPermission]
    
    @OptionalParent(key: CodingKeys.parent.fieldKey)
    public var parent: RRabacRole?
    
    @Children(for: \.$parent)
    public var children: [RRabacRole]
    
    /// Users that have this role
    @Siblings(through: RRabacUserRole.self, from: \.$role, to: \.$user)
    public var users: [RRabacUser]
    
    //  MARK: Lifecycle
    // Vapor migration requires empty init
    public init() {
        self.id = UUIDv5.empty
        self.title = self.migrationName
    }

    public init(id: UUID? = nil, title: String, parent:RRabacRole? = nil) {
        self.id = id
        self.title = title
        self.parent = parent
    }
    
    // MARK: Migration
    public func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(Self.schema)
            .id() // primary key
            .field(CodingKeys.title.fieldKey,            .string, .required)
            .field(CodingKeys.users.fieldKey,            .array(of: .uuid))
            .field(CodingKeys.addedPermissions.fieldKey, .array(of: .uuid))
            .field(CodingKeys.revokedPermissions.fieldKey, .array(of: .uuid))
            .field(CodingKeys.parent.fieldKey,      .uuid)
            .field(CodingKeys.children.fieldKey,      .array(of: .uuid))
            .unique(on: CodingKeys.title.fieldKey)
            .ignoreExisting().create()
    }
    
    public func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(Self.schema).delete()
    }
}
