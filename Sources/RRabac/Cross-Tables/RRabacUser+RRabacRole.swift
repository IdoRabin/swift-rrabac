//
//  RRabacUser+RRabacRole.swift
//  
//
//  Created by Ido on 01/06/2023.
//

import Foundation
import Vapor
import Fluent
import MNUtils
//import DSLogger

final class RRabacUserRole: RRabacModel {
    public static var mnuidTypeStr: String = RRabacMNUIDType.userRole
    static let schema = "rrabac_user_roles"

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
    var id: UUID?
    var mnUID: MNUID? {
        return RRabacUserRoleUID(uid: id!, typeStr: RRabacMNUIDType.userRole)
    }
    
    @Parent(key: CodingKeys.user.fieldKey)
    var user: RRabacUser

    @Parent(key: CodingKeys.role.fieldKey)
    var role: RRabacRole
    
    //  MARK: Lifecycle
    // Vapor migration requires empty init
    init() {}

    init(userID: UUID, roleID: UUID) {
        self.$user.id = userID
        self.$role.id = roleID
    }
    
    // MARK: Migration
    public func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(Self.schema)
            .id() // primary key
            .field(CodingKeys.user.fieldKey, .uuid,  .required)
            .field(CodingKeys.role.fieldKey, .uuid,  .required)
            .ignoreExisting().create()
    }
    
    public func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(Self.schema).delete()
    }
}
