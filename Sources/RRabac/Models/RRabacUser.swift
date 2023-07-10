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

public protocol Userable : AnyObject {
    static var userMNUIDStr : String { get }
    
    var id: UUID? { get }
    var username: String? { get }
    var useremail: String? { get }
    var domain: String? { get }

}

public enum UserableCodingKeys : String, CodingKey, CaseIterable {
    case id = "id"
    case username = "username"
    case useremail = "useremail"
    case domain = "domain"
    
    case addedPermissions = "added_permissions"
    case revokedPermissions = "revoked_permissions"
    
    var fieldKey : FieldKey {
        return .string(self.rawValue)
    }
}

final public class RRabacUser: RRabacModel, Userable {
    public static let userMNUIDStr: String = MNUIDType.user
    public static let schema : String = "rrabac_users"
    
    // MARK: CodingKeys
    enum CodingKeys : String, CodingKey, CaseIterable {
        case username = "username"
        case useremail = "useremail"
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
    public var mnUID : MNUID? {
        guard let uid = self.id else {
            return nil
        }
        return RRabacUserUID(uid: uid)
    }
    
    @OptionalField(key: CodingKeys.username.fieldKey)
    public var username: String?
    
    @OptionalField(key: CodingKeys.useremail.fieldKey)
    public var useremail: String?
    
    @OptionalField(key: CodingKeys.domain.fieldKey)
    public var domain: String?

    
    @Siblings(through: RRabacUserGroup.self, from: \.$user, to: \.$group)
    /// Role groups the user belongs to
    public var groups: [RRabacGroup]
    
    
    /// Roles applying to the user: all their permissions are bestowed upon the user
    @Siblings(through: RRabacUserRole.self, from: \.$user, to: \.$role)
    public var roles: [RRabacRole]
    
    /// Permissions added for the user in addition to the permissions given by the user roles.
    @OptionalField(key: CodingKeys.addedPermissions.fieldKey)
    public var addedPermissions: [RRabacPermission]
    
    /// Permissions revoked for the user overriding all roles and groups the user is associated with
    @OptionalField(key: CodingKeys.revokedPermissions.fieldKey)
    public var revokedPermissions: [RRabacPermission]
    
    //  MARK: Lifecycle
    // Vapor migration requires empty init
    public init() {
        self.addedPermissions = []
        self.revokedPermissions = []
    }

    public init(id: UUID? = nil, username: String?, useremail: String?, domain:String) throws {

        guard (username?.count ?? 0) > 0 &&
              (useremail?.count ?? 0) > 0 else {
            throw MNError(code:.db_failed_init, reason: "RRabacUser failed init because both username and useremail are nil or empty")
        }
        
        self.id = id
        self.username = username
        self.useremail = useremail
        self.domain = domain
        self.addedPermissions = []
        self.revokedPermissions = []
    }
    
    // MARK: Migration
    public func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(Self.schema)
            .id() // primary key
            .field(CodingKeys.username.fieldKey, .string)
            .field(CodingKeys.useremail.fieldKey, .string)
            .field(CodingKeys.domain.fieldKey, .string)
        
            .field(CodingKeys.addedPermissions.fieldKey, .array(of:.uuid))
            .field(CodingKeys.revokedPermissions.fieldKey, .array(of:.uuid))
        
            // Pivots:
            .field(CodingKeys.groups.fieldKey, .array(of:.uuid))
        
            .unique(on: CodingKeys.username.fieldKey, CodingKeys.useremail.fieldKey, CodingKeys.domain.fieldKey)
            .ignoreExisting().create()
    }
    
    public func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(Self.schema).delete()
    }
}
