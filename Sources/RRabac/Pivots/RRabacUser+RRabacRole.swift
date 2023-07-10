//
//  RRabacUserRole.swift
//  
//
//  Created by Ido on 10/07/2023.
//

import Foundation
import Vapor
import Fluent
import MNUtils
//import DSLogger

final public class RRabacUserRole: RRabacModel {
    public static let schema = "user_roles"

    // MARK: CodingKeys
    enum CodingKeys : String, CodingKey, CaseIterable {
        case id = "id"
        case user = "user_id"
        case role = "role_id"
        
        var fieldKey : FieldKey {
            return .string(self.rawValue)
        }
    }
    
    // MARK: Properties
    @ID(key: .id)
    public var id: UUID?
    var mnUID: MNUID? {
        return RRabacUserRoleUID(uid: id!, typeStr: MNUIDType.userRole)
    }
    
    // MARK: Fluent Pivot table (two @Parents are required)
    @Parent(key: CodingKeys.user.fieldKey)
    public var user: RRabacUser

    @Parent(key: CodingKeys.role.fieldKey)
    public var role: RRabacRole

    //  MARK: Lifecycle
    // Vapor migration requires empty init
    init() {}

    init(userID: UUID, roleID: UUID) {
        self.$user.id = userID
        self.$role.id = groupID
    }
    
    // MARK: Migration
    public func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(Self.schema)
            .id() // primary key
            .field(CodingKeys.user.fieldKey,  .uuid,  .required)
            .field(CodingKeys.role.fieldKey,  .uuid,  .required)
            .unique(on: CodingKeys.user.fieldKey, CodingKeys.role.fieldKey)
            .ignoreExisting().create()
    }
    
    public func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(Self.schema).delete()
    }
}
