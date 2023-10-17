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
    public static var mnuidTypeStr: String = RRabacMNUIDType.role
    public  static let schema = "rrabac_roles"
    
    // MARK: CodingKeys
    enum CodingKeys : String, CodingKey, CaseIterable {
        case id = "id"
        case title = "title"
        case users = "user_ids"
        case permissions = "permission_ids"
        case groups = "groups_ids"
        
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
        return RRabacRoleUID(uid: uid)
    }
    
    @Field(key: CodingKeys.title.fieldKey)
    public var title: String // name of the role

//    @Siblings(through: RRabacUserRole.self, from: \.$role, to: \.$user)
//    public var users: [RRabacUser]
//
//    @Siblings(through: RRabacRolePermission.self, from: \.$role, to: \.$permission)
//    public var permissions: [RRabacPermission]
//
//    @Siblings(through: RRabacRoleGroup.self, from: \.$role, to: \.$group)
//    public var groups: [RRabacGroup]

    //  MARK: Lifecycle
    // Vapor migration requires empty init
    public init() {
        self.title = self.migrationName
    }

    public init(id: UUID? = nil, title: String) {
        self.id = id
        self.title = title
    }
    
    // MARK: Migration
    public func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(Self.schema)
            .id() // primary key
            .field(CodingKeys.title.fieldKey, .string, .required)
//            .field(CodingKeys.users.fieldKey, .array(of: .uuid))
//            .field(CodingKeys.permissions.fieldKey, .array(of: .uuid))
//            .field(CodingKeys.groups.fieldKey, .array(of: .uuid))
            .unique(on: CodingKeys.title.fieldKey)
            .ignoreExisting().create()
    }
    
    public func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(Self.schema).delete()
    }
}
