//
//  RRabacUserGroup.swift
//  
//
// Created by Ido Rabin for Bricks on 17/1/2024.

import Foundation
import Vapor
import Fluent
import MNUtils

final public class RRabacGroup: RRabacModel {
    public static var mnuidTypeStr: String = RRabacMNUIDType.group
    public static let schema = "rrabac_group"

    // MARK: CodingKeys
    enum CodingKeys : String, CodingKey, CaseIterable {
        case id = "id"
        case title = "title"
        case desc = "desc"
        case domain = "domain"
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

    @Field(key: CodingKeys.title.fieldKey)
    public var title: String

    @Field(key: CodingKeys.desc.fieldKey)
    public var desc: String
    
    @Field(key: CodingKeys.domain.fieldKey)
    public var domain: String

    // The users assigned to this group
    @Siblings(through: RRabacUserGroup.self, from: \.$group, to: \.$user)
    public var users: [RRabacUser]

    // The roles assigned to this group
    @Siblings(through: RRabacRoleGroup.self, from: \.$group, to: \.$role)
    public var roles: [RRabacRole]
    
    //  MARK: Lifecycle
    // Vapor migration requires empty init
    public init() {
    }

    public init(id: UUID? = nil, title: String, domain:String, roles: [RRabacRole]?, desc: String = "") {
        self.id = id
        self.title = title
        self.domain = domain
        self.desc = desc
        // self.roles = roles ?? []
    }
    
    // MARK: Migration
    public func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(Self.schema)
            .id() // primary key
            .field(CodingKeys.title.fieldKey, .string, .required)
            .field(CodingKeys.desc.fieldKey, .string)
            .field(CodingKeys.domain.fieldKey, .string)
            .field(CodingKeys.roles.fieldKey, .string)
            .field(CodingKeys.users.fieldKey, .string)
            .unique(on: CodingKeys.title.fieldKey)
            .ignoreExisting().create()
    }
    
    public func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(Self.schema).delete()
    }
}
