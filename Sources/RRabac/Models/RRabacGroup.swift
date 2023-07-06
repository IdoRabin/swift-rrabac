//
//  RRabacUserGroup.swift
//  
//
//  Created by Ido on 01/06/2023.
//

import Foundation
import Vapor
import Fluent
import MNUtils
import DSLogger

final public class RRabacGroup: Model, Content, MNUIDable {
    public static let schema = "rrabac_group"

    // MARK: CodingKeys
    enum CodingKeys : String, CodingKey, CaseIterable {
        case id = "id"
        case name = "name"
        case desc = "desc"
        case domain = "domain"
        case defaultRoles = "default_role_ids"
        case users = "user_ids"
        case roles = "role_ids"
        
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
        return RRabacGroupUID(uid: uid)
    }

    @Field(key: "name")
    public var name: String

    @Field(key: "desc")
    public var desc: String
    
    @Field(key: "domain")
    public var domain: String

    public var default_roles: [RRabacRole] = []

    // The users assigned to this group
    @Siblings(through: RRabacUserGroup.self, from: \.$group, to: \.$user)
    public var users: [RRabacUser]

    // The roles assigned to this group
    @Siblings(through: RRabacRoleGroup.self, from: \.$group, to: \.$role)
    public var roles: [RRabacRole]
    
    //  MARK: Lifecycle
    // Vapor migration requires empty init
    public init() {
        default_roles = []
    }

    public init(id: UUID? = nil, name: String, domain:String, roles: [RRabacRole]?, desc: String = "") {
        self.id = id
        self.name = name
        self.domain = domain
        self.desc = desc
        self.roles = roles ?? []
        self.default_roles = roles ?? []
    }
    
    // MARK: Migration
    public func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema(RRabacHitsoryItem.schema)
            .id() // primary key
            .field(CodingKeys.name.fieldKey, .string, .required)
            .field(CodingKeys.desc.fieldKey, .string)
            .field(CodingKeys.domain.fieldKey, .string)
            .field(CodingKeys.roles.fieldKey, .string)
            .field(CodingKeys.defaultRoles.fieldKey, .string)
            .field(CodingKeys.users.fieldKey, .string)
            .ignoreExisting().create()
    }
    
    public func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(Self.schema).delete()
    }
}
