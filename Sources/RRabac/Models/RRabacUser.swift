//
//  RRABACUser.swift
//  
//
//  Created by Ido on 31/05/2023.
//

import Foundation
import Vapor
import Fluent
import MNUtils
import DSLogger

final public class RRabacUser: RRabacModel {
    public static var mnuidStr : String { "RRBC_USR" }
    public static var schema : String { "rrabac_users" }
    
    // MARK: CodingKeys
    enum CodingKeys : String, CodingKey, CaseIterable {
        case id = "id"
        case mnUserId = "mn_user_id"
        case mnUserInfo = "mn_user_info_id"
        case domain = "domain"
        
        case roles = "rrabac_role_ids"
        case groups = "rrabac_group_ids"
        
        // Manual granularity on a per-user basis
        case addedPermissions = "rrabac_added_permission_ids"
        case revokedPermissions = "rrabac_revoked_permission_ids"
        
        var fieldKey : FieldKey {
            return .string(self.rawValue)
        }
    }
    
    // MARK: Properties
    @ID(key: .id)
    public var id: UUID?
    
    @OptionalField(key: CodingKeys.mnUserId.fieldKey)
    public var sysUserId: UUID?
    
    @OptionalField(key: CodingKeys.mnUserInfo.fieldKey)
    public var sysUserInfo: UUID?
    
    @OptionalField(key: CodingKeys.domain.fieldKey)
    public var domain: String?
    
    /// Roles applying to the user: all their permissions are bestowed upon the user
    @Siblings(through: RRabacUserRole.self, from: \.$user, to: \.$role)
    public var roles: [RRabacRole]
    
    /// Permissions added for the user in addition to the permissions given by the user roles.
    @Field(key: CodingKeys.addedPermissions.fieldKey)
    public var addedPermissions: [RRabacPermission]
    
    /// Permissions revoked for the user overriding all roles and groups the user is associated with
    @Field(key: CodingKeys.revokedPermissions.fieldKey)
    public var revokedPermissions: [RRabacPermission]
    
    //  MARK: Lifecycle
    // Vapor migration requires empty init
    public init() {
        self.addedPermissions = []
        self.revokedPermissions = []
    }

    public init(id: UUID? = nil, domain:String?) throws {
        self.id = id
        self.domain = domain
        self.addedPermissions = []
        self.revokedPermissions = []
    }
    
    // MARK: Migration
    public func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(Self.schema)
            .id() // primary key
            .field(CodingKeys.domain.fieldKey, .string)
        
            .field(CodingKeys.addedPermissions.fieldKey, .array(of:.uuid))
            .field(CodingKeys.revokedPermissions.fieldKey, .array(of:.uuid))
        
            // Pivots:
            .field(CodingKeys.groups.fieldKey, .array(of:.uuid))
            .field(CodingKeys.roles.fieldKey, .array(of:.uuid))
            .unique(on:.id, CodingKeys.domain.fieldKey)
            .ignoreExisting().create()
    }
    
    public func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(Self.schema).delete()
    }
}
