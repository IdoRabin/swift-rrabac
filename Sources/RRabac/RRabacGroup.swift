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
    public static let schema = "users"

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

    @Field(key: "description")
    public var description: String
    
    @Field(key: "domain")
    public var domain: String

    public var default_roles: [RRabacRole] = []

    @Siblings(through: RRabacUserGroup.self, from: \.$group, to: \.$user)
    public var users: [RRabacUser]

    @Siblings(through: RRabacRoleGroup.self, from: \.$group, to: \.$role)
    public var roles: [RRabacRole]
    
    public init() {
        default_roles = []
    }

    public init(id: UUID? = nil, name: String, domain:String, roles: [RRabacRole]?) {
        self.id = id
        self.name = name
        self.domain = domain
        self.roles = roles ?? []
        self.default_roles = roles ?? []
    }
}
